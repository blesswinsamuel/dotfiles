package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

type HostState struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	IP      string `json:"ip"`
	Region  string `json:"region"`
	Status  string `json:"status"`
	Size    string `json:"size"`
	ImageID string `json:"image_id,omitempty"`
}

type ImageState struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	Region string `json:"region"`
	Status string `json:"status"`
}

type FirewallState struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	DropletID string `json:"droplet_id"`
}

func (c *Config) buildHostPath() string { return filepath.Join(c.StateDir, "build-host.json") }
func (c *Config) devHostPath() string   { return filepath.Join(c.StateDir, "dev-host.json") }
func (c *Config) imagePath() string     { return filepath.Join(c.StateDir, "image.json") }
func (c *Config) firewallPath() string  { return filepath.Join(c.StateDir, "firewall.json") }

func writeJSON(path string, v any) error {
	b, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return err
	}
	b = append(b, '\n')
	return os.WriteFile(path, b, 0o644)
}

func readJSON[T any](path string) (*T, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var v T
	if err := json.Unmarshal(b, &v); err != nil {
		return nil, err
	}
	return &v, nil
}

func loadHost(path string) (*HostState, error) {
	h, err := readJSON[HostState](path)
	if err != nil {
		return nil, fmt.Errorf("read %s: %w", path, err)
	}
	return h, nil
}
