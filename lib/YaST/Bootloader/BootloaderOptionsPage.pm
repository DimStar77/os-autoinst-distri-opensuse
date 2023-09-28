# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: The class introduces all accessing methods for Bootloader Options tab
# in Boot Loader Settings.
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

package YaST::Bootloader::BootloaderOptionsPage;
use parent 'Installation::Navigation::NavigationBase';
use strict;
use warnings;
use testapi;
use version_utils qw(is_tumbleweed is_staging);


sub init {
    my $self = shift;
    $self->SUPER::init();
    my $widget = is_y2bootloader_5() ? "\"Bootloader::Grub2Widget::TimeoutWidget\"" : "\"Bootloader::TimeoutWidget\"";
    $self->{txb_grub_timeout} = $self->{app}->textbox({id => $widget});
    return $self;
}

sub is_shown {
    my ($self) = @_;
    $self->{txb_grub_timeout}->exist();
}

sub is_y2bootloader_5 {
    # yast2-bootloader 5.x introduced support for different bootloaders than grub, which resulted in the
    # internal tree structure of the widgets to be updated
    # to be extended here whenever new version show up with the new yast version
    return is_tumbleweed || is_staging;
}

sub set_grub_timeout {
    my ($self, $timeout) = @_;
    $self->{txb_grub_timeout}->set($timeout);
}

1;
