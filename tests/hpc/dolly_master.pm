# SUSE's openQA tests
#
# Copyright @ SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Test Dolly package duplication block on all nodes, create sha256 for validation
# Maintainer: Kernel QE <kernel-qa@suse.de>

use Mojo::Base qw(hpcbase btrfs_test), -signatures;
use testapi;
use serial_terminal 'select_serial_terminal';
use lockapi;
use utils;

our $test_dir = "/mnt/test";
our $test_dev;

sub run ($self) {
    $self->set_playground_disk();    # sets PLAYGROUNDDISK variable
    $test_dev = get_required_var('PLAYGROUNDDISK');
    record_info 'test_dev', "$test_dev";
    my $nodes = get_required_var("CLUSTER_NODES");
    select_serial_terminal();
    zypper_call('in dolly');
    barrier_wait("DOLLY_INSTALLATION_FINISHED");

    assert_script_run("mkfs.ext4 -v $test_dev");
    assert_script_run("mkdir -p $test_dir");
    assert_script_run("mount $test_dev $test_dir");
    assert_script_run("dd if=/dev/zero of=${test_dir}/data10Gb bs=1M count=1000");
    assert_script_run("dd if=/dev/zero of=${test_dir}/data200M bs=1M count=200");
    assert_script_run("sha256sum ${test_dir}/data* > ${test_dir}/hashes.sha256");
    assert_script_run("umount $test_dir");
    barrier_wait("DOLLY_SERVER_READY");
    my $server_hostname = get_required_var("HOSTNAME");
    my @slave_nodes = $self->slave_node_names();
    my $client_hostnames = join(',', @slave_nodes);
    # timeout should be in sync with slave_node
    assert_script_run("dolly -v -S $server_hostname -H $client_hostnames -I $test_dev -O $test_dev", timeout => 1600);
    barrier_wait("DOLLY_DONE");
}

sub test_flags ($self) {
    return {fatal => 1, milestone => 1};
}

sub post_fail_hook ($self) {
    $self->destroy_test_barriers();
}

1;
