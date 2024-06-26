# SUSE's openQA tests
#
# Copyright 2016 SUSE LLC
# SPDX-License-Identifier: FSFAP
#
# Summary: This test verifies sle and windows guest migration from xen to kvm using virt-v2v.
#          This is the part to run on destination host.
# Maintainer: alice <xlai@suse.com>

use base multi_machine_job_base;
use strict;
use warnings;
use testapi;
use lockapi;
use mmapi;
use virt_utils;
use virt_autotest::utils;

sub get_script_run {
    my ($self) = @_;

    my $src_ip = $self->get_var_from_parent('SRC_IP');
    my $src_user = $self->get_var_from_parent('SRC_USER');
    my $src_pass = $self->get_var_from_parent('SRC_PASS');
    handle_sp_in_settings_with_sp0("GUEST_LIST");
    my $guests = get_var("GUEST_LIST");
    our $virt_v2v_log;
    my ($guest_regcode, $guest_regcode_ltss) = get_guest_regcode;
    my $pre_test_cmd = "/usr/share/qa/virtautolib/lib/virt_v2v_test.sh -s $src_ip -u $src_user -p $src_pass -i \"$guests\"  -o \"$guest_regcode\" -O \"$guest_regcode_ltss\" 2>&1 | tee $virt_v2v_log";

    return "$pre_test_cmd";
}

sub run {
    my ($self) = @_;

    mutex_lock('SRC_READY_TO_START');
    mutex_unlock('SRC_READY_TO_START');

    my $timeout = get_var("MAX_JOB_TIME", "10800") - 30;
    our $virt_v2v_log_dir = "/tmp/virt-v2v/";
    our $virt_v2v_log = "$virt_v2v_log_dir/virt-v2v.log";
    my $log_dirs = "$virt_v2v_log_dir /var/log/libvirt /var/log/messages";

    assert_script_run("mkdir -p $virt_v2v_log_dir");

    $self->run_test($timeout, "Congratulations! All tests passed!", "no", "yes", "$log_dirs", "virt-v2v-kvm-dst-logs");
}

1;
