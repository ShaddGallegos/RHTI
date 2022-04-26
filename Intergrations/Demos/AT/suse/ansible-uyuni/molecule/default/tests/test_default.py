"""
Molecule unit tests
"""
import os
import configparser
import testinfra.utils.ansible_runner

TESTINFRA_HOSTS = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_lvm(host):
    """
    test if storage was set-up correctly
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    if ansible_vars["ansible_facts"]["uyuni_use_lvm"]:
        # check file systems
        for filesys in ansible_vars["ansible_facts"]["uyuni_filesystems"]:
            assert host.mount_point(filesys["mountpoint"]).exists
            assert host.mount_point(
                filesys["mountpoint"]
                ).filesystem == filesys["type"]


def test_packages(host):
    """
    check if packages are installed
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    # check dependencies and Uyuni packages
    for pkg in ansible_vars["ansible_facts"]["uyuni_core_packages"] + \
            ansible_vars["ansible_facts"]["uyuni_packages"]:
        assert host.package(pkg).is_installed


def test_setup_complete(host):
    """
    check if installation files exist
    """
    with host.sudo():
        for state_file in [
                "/root/.MANAGER_SETUP_COMPLETE",
                "/root/.MANAGER_INITIALIZATION_COMPLETE"]:
            assert host.file(state_file).exists


def test_ports_listen(host):
    """
    check if ports are listening
    """
    for port in [22, 80, 443, 4505, 4506]:
        assert host.socket("tcp://0.0.0.0:%s" % port).is_listening


def test_firewall(host):
    """
    check if firewall is configured properly
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    # check if services are enabled
    if ansible_vars["ansible_facts"]["uyuni_firewall_config"]:
        with host.sudo():
            cmd_fw = host.run("firewall-cmd --list-services")
            for srv in ansible_vars["ansible_facts"]["uyuni_firewall_services"]:    # noqa: 204
                assert srv in cmd_fw.stdout.strip()


def test_org(host):
    """
    check if organization is accessible
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    # check if organization exists
    cmd_org = host.run(
        "spacecmd -q -u %s -p %s org_list",
        ansible_vars["ansible_facts"]["uyuni_org_login"],
        ansible_vars["ansible_facts"]["uyuni_org_password"]
        )
    assert cmd_org.stdout.strip() == ansible_vars["ansible_facts"]["uyuni_org_name"]    # noqa: 204


def test_errata(host):
    """
    check if CEFS/DEFS are installed properly
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    if ansible_vars["ansible_facts"]["uyuni_cefs_setup"]:
        # check package dependencies
        for pkg in ansible_vars["ansible_facts"]["uyuni_cefs_packages"]:
            assert host.package(pkg).is_installed
        # check script
        assert host.file(
            "{}/errata-import.pl" % ansible_vars["ansible_facts"]["uyuni_cefs_path"]    # noqa: 204
            ).exists
        # check cronjobs
        if ansible_vars["ansible_facts"]["uyuni_cefs_setup_cronjob"]:
            assert host.file("/etc/cron.d/errata-cefs").exists
        if ansible_vars["ansible_facts"]["uyuni_defs_setup_cronjob"]:
            assert host.file("/etc/cron.d/errata-defs").exists


def test_channels(host):
    """
    check if supplied channels were created
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    # get spacewalk-common-channels definitions from client
    with host.sudo():
        definition_file = host.file(
            "/etc/rhn/spacewalk-common-channels.ini"
            ).content_string
    definitions = configparser.RawConfigParser(allow_no_value=True)
    definitions.read_string(definition_file)

    # check channels if defined
    if len(ansible_vars["ansible_facts"]["uyuni_channels"]) > 0:
        # get all repositories
        with host.sudo():
            cmd_channels = host.run(
                "spacecmd -q -u %s -p %s repo_list",
                ansible_vars["ansible_facts"]["uyuni_org_login"],
                ansible_vars["ansible_facts"]["uyuni_org_password"]
            )
        for channel in ansible_vars["ansible_facts"]["uyuni_channels"]:
            # get repository name (it ain't nice, but it's honest work)
            repo_name = definitions[channel["name"]]["name"]
            repo_name = "External - %s" % repo_name.replace(
                "%(arch)s", channel["arch"]
                )
            # ensure that repository exists
            assert repo_name in cmd_channels.stdout.strip().split("\n")


def test_monitoring_packages(host):
    """
    check if monitoring packages have been installed
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    # set packages
    pkgs = []
    if ansible_vars["ansible_facts"]["uyuni_enable_monitoring"]:
        pkgs = pkgs + ansible_vars["ansible_facts"]["uyuni_monitoring_packages"]
    if ansible_vars["ansible_facts"]["uyuni_install_monitoring_formulas"]:
        pkgs = pkgs + ansible_vars["ansible_facts"]["uyuni_monitoring_formulas_packages"]
    # check packages
    for pkg in pkgs:
        print(pkg)
        assert host.package(pkg).is_installed


def test_monitoring_enabled(host):
    """
    check if monitoring is enabled
    """
    # get variables from file
    ansible_vars = host.ansible(
        "include_vars",
        "file=molecule/default/vars/main.yml"
    )
    # check configuration
    if ansible_vars["ansible_facts"]["uyuni_enable_monitoring"]:
        with host.sudo():
            rhn_cfg = host.file("/etc/rhn/rhn.conf")
            assert rhn_cfg.contains("prometheus_monitoring_enabled")
    # check status
    with host.sudo():
        mon_status = host.run("mgr-monitoring-ctl status")
        assert "error" not in mon_status.stdout.strip().lower()
