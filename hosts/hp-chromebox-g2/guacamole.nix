{
  # Clientless remote desktop in the browser, reached over Tailscale only.
  # guacd listens on loopback; Tomcat serves the web UI on 8080. The firewall
  # admits only tailscale0, so none of this is exposed on the wired LAN.
  services.guacamole-server = {
    enable = true;
    host = "127.0.0.1";
    port = 4822;
  };

  services.guacamole-client = {
    enable = true;
    settings = {
      guacd-hostname = "127.0.0.1";
      guacd-port = 4822;
    };
    # Static file auth (PLAIN/MD5 only); the MD5 digest lives in the XML.
    # The client module enables Tomcat and installs the WAR into it.
    userMappingXml = ./guacamole-user-mapping.xml;
  };

  # Reach the UI at http://<host>.li-danio.ts.net:8080/guacamole over Tailscale.
  # guacd dials the local x11vnc on 127.0.0.1:5900.
}
