package main

import (
	"bytes"
	"fmt"
	"io"
	"maps"
	"net/url"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"runtime"
	"strings"
	"text/template"

	"filippo.io/age"
	"filippo.io/age/agessh"
	"github.com/goccy/go-yaml"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/sergi/go-diff/diffmatchpatch"
	"howett.net/plist"
)

type Config struct {
	Profiles map[string]Profile `yaml:"profiles"`
	Hosts    map[string]Profile `yaml:"hosts"`
}

type Profile struct {
	Files         map[string]File `yaml:"files"`
	MacOS         MacOs           `yaml:"macos"`
	SecretProfile string          `yaml:"secretProfile"`
}

func (p *Profile) MergeProfile(p2 Profile) {
	if p.Files == nil {
		p.Files = p2.Files
	} else {
		maps.Copy(p.Files, p2.Files)
	}
	if p.MacOS.Dock.Entries == nil {
		p.MacOS.Dock.Entries = p2.MacOS.Dock.Entries
	}
	if p.SecretProfile == "" {
		p.SecretProfile = p2.SecretProfile
	}
}

type MacOs struct {
	Dock MacOsDock `yaml:"dock"`
}

type MacOsDock struct {
	Entries []DockEntry `yaml:"entries"`
}

type DockEntry struct {
	Path    string            `yaml:"path"`
	Section string            `yaml:"section"`
	Options map[string]string `yaml:"options"`
}

type File struct {
	Source    string `yaml:"source"`
	Operation string `yaml:"operation"`
	Template  bool   `yaml:"template"`
}

func getComputerName() (string, error) {
	switch runtime.GOOS {
	case "windows":
		return "", nil
	case "darwin":
		// run `scutil --get LocalHostName`
		hn, err := exec.Command("scutil", "--get", "LocalHostName").Output()
		if err != nil {
			return "", err
		}
		return strings.TrimSpace(string(hn)), nil
	case "linux":
		return "", nil
	default:
		return "", nil
	}
}

type SecretConfig map[string]any

func getSecretConfig() (map[string]SecretConfig, error) {
	privateKeyFile := path.Join(os.Getenv("HOME"), ".ssh", "id_ed25519")
	privateKey, err := os.ReadFile(privateKeyFile)
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to read private key")
	}
	identity, err := agessh.ParseIdentity(privateKey)
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to parse private key")
	}

	secretConfig := map[string]SecretConfig{}
	secretConfigFile, err := filepath.Abs("../secrets/config.json.age")
	if err != nil {
		return nil, err
	}
	f, err := os.Open(secretConfigFile)
	if err != nil {
		return nil, err
	}
	r, err := age.Decrypt(f, identity)
	if err != nil {
		return nil, fmt.Errorf("failed to decrypt: %w", err)
	}
	out := &bytes.Buffer{}
	if _, err := io.Copy(out, r); err != nil {
		return nil, err
	}
	if err := yaml.Unmarshal(out.Bytes(), &secretConfig); err != nil {
		return nil, err
	}
	return secretConfig, nil
}

func main() {
	zerolog.SetGlobalLevel(zerolog.InfoLevel)
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	configFile, err := os.ReadFile("home.yaml")
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to read config file")
	}
	config := Config{}
	if err := yaml.Unmarshal([]byte(configFile), &config); err != nil {
		fmt.Println(err)
		log.Fatal().Err(err).Msgf("failed to unmarshal")
	}

	runtimeOS := runtime.GOOS
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to get hostname")
	}
	computerName, err := getComputerName()
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to get computer name")
	}
	log.Info().Str("os", runtimeOS).Str("hostname", hostname).Str("computerName", computerName).Msgf("starting")
	// profiles := []Profile{}
	// profiles = append(profiles, config.Profiles["common"])
	// profiles = append(profiles, config.Profiles[runtimeOS])
	// if profile, ok := config.Hosts[hostname]; ok {
	// 	profiles = append(profiles, profile)
	// } else {
	// 	profiles = append(profiles, config.Hosts[computerName])
	// }
	profile := config.Profiles["common"]
	if p, ok := config.Profiles[runtimeOS]; ok {
		profile.MergeProfile(p)
	}
	if p, ok := config.Hosts[hostname]; ok {
		profile.MergeProfile(p)
	} else if p, ok := config.Hosts[computerName]; ok {
		profile.MergeProfile(p)
	}

	secretConfigAll, err := getSecretConfig()
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to get secret config")
	}
	secrets := SecretConfig{}
	maps.Copy(secrets, secretConfigAll["common"])
	maps.Copy(secrets, secretConfigAll[profile.SecretProfile])
	log.Info().Str("profile", profile.SecretProfile).Interface("secrets", secrets).Msgf("got secret config")

	for destination, file := range profile.Files {
		if file.Operation == "" {
			file.Operation = "symlink"
		}
		destination = path.Join(os.Getenv("HOME"), destination)
		source, err := filepath.Abs(file.Source)
		if err != nil {
			log.Fatal().Err(err).Msgf("failed to get absolute path")
		}
		log.Debug().Str("source", source).Str("destination", destination).Str("operation", file.Operation).Msgf(">> processing file")
		switch file.Operation {
		case "symlink":
			if stats, err := os.Lstat(destination); err == nil {
				// destination exists
				if stats.Mode()&os.ModeSymlink != 0 {
					resolvedLink, err := os.Readlink(destination)
					if err != nil {
						log.Fatal().Err(err).Msgf("failed to read symlink")
					}
					if resolvedLink == source {
						log.Debug().Str("destination", destination).Msgf("symlink already exists")
						continue
					}

					log.Info().Str("destination", destination).Msgf("removing existing symlink")
					if err := os.Remove(destination); err != nil {
						log.Fatal().Err(err).Msgf("failed to remove existing file")
					}
				} else {
					log.Fatal().Str("destination", destination).Msgf("destination already exists")
				}
			}

			log.Info().Str("source", source).Str("destination", destination).Msgf("creating symlink")
			if err := os.Symlink(source, destination); err != nil {
				log.Fatal().Err(err).Msgf("failed to create symlink")
			}
		case "copy":
			if stats, err := os.Lstat(destination); err == nil {
				// destination exists
				if stats.Mode()&os.ModeSymlink != 0 {
					log.Info().Str("destination", destination).Msgf("removing existing symlink")
					if err := os.Remove(destination); err != nil {
						log.Fatal().Err(err).Msgf("failed to remove existing file")
					}
				} else if stats.Mode().IsRegular() {
					// no problem - will be overwritten
				} else {
					log.Fatal().Str("destination", destination).Msgf("destination already exists")
				}
				// if stats.Mode().IsRegular() {
				// 	log.Info().Str("destination", destination).Msgf("removing existing file")
				// 	if err := os.Remove(destination); err != nil {
				// 		log.Fatal().Err(err).Msgf("failed to remove existing file")
				// 	}
				// }
			}

			data, err := os.ReadFile(source)
			if err != nil {
				log.Fatal().Err(err).Msgf("failed to read file")
			}
			if file.Template {
				t, err := template.New("").Parse(string(data))
				if err != nil {
					log.Fatal().Err(err).Msgf("failed to parse template")
				}
				buf := bytes.NewBuffer([]byte{})
				if err := t.Execute(buf, map[string]any{
					"Secrets": secrets,
				}); err != nil {
					log.Fatal().Err(err).Msgf("failed to execute template")
				}
				data = buf.Bytes()
			}

			if destFile, err := os.ReadFile(destination); err == nil {
				if bytes.Equal(data, destFile) {
					log.Debug().Str("destination", destination).Msgf("file already exists")
					continue
				}
			}
			log.Info().Str("source", source).Str("destination", destination).Msgf("copying file")
			if err := os.WriteFile(destination, data, 0644); err != nil {
				log.Fatal().Err(err).Msgf("failed to write file")
			}
		default:
			log.Fatal().Str("operation", file.Operation).Msgf("unsupported operation")
		}
	}
	for i, entry := range profile.MacOS.Dock.Entries {
		if entry.Section == "" {
			entry.Section = "apps"
		}
		if entry.Path != "" {
			entry.Path = strings.Replace(entry.Path, "$HOME", os.Getenv("HOME"), -1)
		}
		profile.MacOS.Dock.Entries[i] = entry
	}
	// profile.MacOS.Dock.Entries
	dockEntries, err := getCurrentDockEntries()
	if err != nil {
		log.Fatal().Err(err).Msgf("failed to get current dock entries")
	}
	// fmt.Println(dockEntries)
	if isEqual := printDockDiff(dockEntries, profile.MacOS.Dock.Entries); !isEqual {
		log.Info().Msgf("updating dock entries")
		// https://gist.github.com/kamui545/c810eccf6281b33a53e094484247f5e8
		if err := exec.Command("dockutil", "--remove", "all", "--no-restart").Run(); err != nil {
			log.Fatal().Err(err).Msgf("failed to remove all dock entries")
		}
		for _, entry := range profile.MacOS.Dock.Entries {
			cmdArgs := []string{"--no-restart", "--add", entry.Path}
			cmdArgs = append(cmdArgs, "--section", entry.Section)
			for k, v := range entry.Options {
				cmdArgs = append(cmdArgs, "--"+k, v)
			}
			if err := exec.Command("dockutil", cmdArgs...).Run(); err != nil {
				log.Fatal().Interface("entry", entry).Err(err).Msgf("failed to add dock entry")
			}
		}
		if err := exec.Command("killall", "Dock").Run(); err != nil {
			log.Fatal().Err(err).Msgf("failed to restart dock")
		}
	}
}

func printDockDiff(current, desired []DockEntry) bool {
	currentYaml := &bytes.Buffer{}
	if err := yaml.NewEncoder(currentYaml).Encode(current); err != nil {
		log.Fatal().Err(err).Msgf("failed to encode current dock entries")
	}
	desiredYaml := &bytes.Buffer{}
	if err := yaml.NewEncoder(desiredYaml).Encode(desired); err != nil {
		log.Fatal().Err(err).Msgf("failed to encode desired dock entries")
	}
	dmp := diffmatchpatch.New()
	isEqual := currentYaml.String() == desiredYaml.String()
	if isEqual {
		return true
	}
	diffs := dmp.DiffMain(currentYaml.String(), desiredYaml.String(), false)
	fmt.Println(dmp.DiffPrettyText(diffs))
	return false
}

func getCurrentDockEntries() ([]DockEntry, error) {
	var entries []DockEntry
	plistFile, err := os.Open(path.Join(os.Getenv("HOME"), "Library/Preferences/com.apple.dock.plist"))
	if err != nil {
		return nil, fmt.Errorf("failed to read file: %w", err)
	}
	decoder := plist.NewDecoder(plistFile)
	decodedMap := map[string]any{}
	if err := decoder.Decode(&decodedMap); err != nil {
		return nil, fmt.Errorf("failed to decode plist: %w", err)
	}
	persistentApps, ok := decodedMap["persistent-apps"].([]any)
	if !ok {
		return nil, fmt.Errorf("failed to get persistent-apps")
	}
	// https://github.com/kcrawford/dockutil/blob/640c520ce142a5f21e56fda88a95b4e4d6576042/Sources/DockUtil/Dock.swift#L275-L324
	addEntry := func(entry any, section string) error {
		entryMap, ok := entry.(map[string]any)
		if !ok {
			return fmt.Errorf("failed to get entry")
		}
		tileData, ok := entryMap["tile-data"].(map[string]any)
		if !ok {
			return fmt.Errorf("failed to get tile-data")
		}
		tileType, ok := entryMap["tile-type"].(string)
		if !ok {
			return fmt.Errorf("failed to get tile-type")
		}
		// delete(tileData, "book")
		// fmt.Println(entryMap)
		dockEntry := DockEntry{Section: section}
		// https://github.com/kcrawford/dockutil/blob/640c520ce142a5f21e56fda88a95b4e4d6576042/Sources/DockUtil/DockUtil.swift

		updatePath := func() error {
			if fileData, ok := tileData["file-data"].(map[string]any); ok {
				dockEntry.Path = fileData["_CFURLString"].(string)
				u, err := url.Parse(dockEntry.Path)
				if err != nil {
					return err
				}
				dockEntry.Path = u.Path
			}
			return nil
		}
		switch tileType {
		case "file-tile":
			if err := updatePath(); err != nil {
				return err
			}
		case "directory-tile":
			if err := updatePath(); err != nil {
				return err
			}
			arrangement, ok := tileData["arrangement"].(uint64)
			if !ok {
				fmt.Printf("%T\n", tileData["arrangement"])
				return fmt.Errorf("failed to get arrangement")
			}
			displayas, ok := tileData["displayas"].(uint64)
			if !ok {
				return fmt.Errorf("failed to get displayas")
			}
			showas, ok := tileData["showas"].(uint64)
			if !ok {
				return fmt.Errorf("failed to get showas")
			}
			// https://github.com/kcrawford/dockutil/blob/640c520ce142a5f21e56fda88a95b4e4d6576042/Sources/DockUtil/DockUtil.swift
			sort := map[uint64]string{1: "name", 2: "dateadded", 3: "datemodified", 4: "datecreated", 5: "kind"}[arrangement]
			display := map[uint64]string{1: "folder", 0: "stack"}[displayas]
			view := map[uint64]string{0: "auto", 1: "fan", 2: "grid", 3: "list"}[showas]
			dockEntry.Options = map[string]string{"sort": sort, "display": display, "view": view}
		case "spacer-tile":
			dockEntry.Options = map[string]string{"type": "spacer"}
			// case "url-tile":
		}
		// fmt.Println(dockEntry)
		entries = append(entries, dockEntry)
		return nil
	}
	for _, entry := range persistentApps {
		if err := addEntry(entry, "apps"); err != nil {
			return nil, err
		}
	}
	persistentOthers, ok := decodedMap["persistent-others"].([]any)
	if !ok {
		return nil, fmt.Errorf("failed to get persistent-others")
	}
	for _, entry := range persistentOthers {
		if err := addEntry(entry, "others"); err != nil {
			return nil, err
		}
	}
	return entries, nil
}
