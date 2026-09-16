package main

import (
	"context"
	"fmt"
	"os"
	"strings"
)

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(2)
	}

	cfg, err := loadConfig()
	if err != nil {
		fatal(err)
	}

	ctx := context.Background()
	var runErr error
	switch os.Args[1] {
	case "build-host":
		runErr = cmdBuildHost(ctx, cfg, os.Args[2:])
	case "image":
		runErr = cmdImage(ctx, cfg, os.Args[2:])
	case "dev":
		runErr = cmdDev(ctx, cfg, os.Args[2:])
	case "help", "-h", "--help":
		usage()
	default:
		fmt.Fprintf(os.Stderr, "unknown command: %s\n", os.Args[1])
		usage()
		os.Exit(2)
	}
	if runErr != nil {
		fatal(runErr)
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: go run ./do <command>

Commands:
  build-host up|down|ssh
  image build [--teardown]
  dev up|down|ssh|block-ports

Auth / config via env:
  DIGITALOCEAN_ACCESS_TOKEN (or DO_TOKEN)
  DO_SSH_KEY
  DO_REGION (optional)
  IMAGE_HTTP_PORT (optional, default 8765)
`)
}

func fatal(err error) {
	msg := strings.TrimSpace(err.Error())
	fmt.Fprintln(os.Stderr, msg)
	os.Exit(1)
}
