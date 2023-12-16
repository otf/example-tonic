{ pkgs
, package
}:

{
  name = "System test of gRPC";
  nodes = {
    server = {
      systemd.services.server = {
        wantedBy = [ "multi-user.target" ];
        script = "${package}/bin/helloworld-server";
      };
      networking.firewall.enable = false;
    };
    client = {
      environment.systemPackages = [
        package
      ];
    };
  };

  testScript = ''
    start_all()

    with subtest('connect to server'):
      client.wait_for_unit('default.target');
      server.wait_for_unit('server.service');
      assert 'Hello Tonic!' in client.succeed('${package}/bin/helloworld-client http://server:50051')
  '';
}
