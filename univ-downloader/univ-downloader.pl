#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Socket;
use Net::Pcap;
use HTTP::Request;
use Data::Hexdumper qw(hexdump);
use NetPacket::Ethernet;
use NetPacket::IP;
use NetPacket::TCP;
use Readonly;
Readonly my $ppp0 => 'ppp0';
Readonly my $wlan0 => 'wlan0';
Readonly my $buffer_size => 65535; # set maxium buffer size
Readonly my $infinite => -1;
Readonly my $filter_cmd => 
	'( port 80 or port 8080 ) and ( tcp[tcpflags] & (tcp-push|tcp-ack) !=0)';
my $err='';
my %devinfo;
my $found_if=$ppp0;
my @dev=pcap_findalldevs(\%devinfo,\$err);
check_err($err);
if (!defined $devinfo{$ppp0}) {
	warn "not priviledge, or not activated ppp0 interface try wlan\n";
	if (!defined $devinfo{$wlan0}) {
		die "uh? wlan0 also doesn't exsist,abort\n";
	}
	$found_if=$wlan0;
}
my ($net,$mask);
pcap_lookupnet($found_if,\$net,\$mask,\$err);
check_err($err);
my $pcap = pcap_open_live($found_if,$buffer_size,1,0,\$err);
check_err($err);
my $filter;
pcap_compile($pcap,\$filter,$filter_cmd,1,$mask);
check_err($err);
pcap_setfilter($pcap,$filter);
my $link_type_name=pcap_datalink_val_to_name(pcap_datalink($pcap));
pcap_loop($pcap,$infinite,\&search_method,$link_type_name);
pcap_close($pcap);
exit (0);
sub search_method {
	my ($link_type_name,$header,$packet)=@_;
	use bytes;
	my $data_stripped_link_header;
	my $protocol_type_of_link_header;
	if ($link_type_name eq "LINUX_SLL") {
		$data_stripped_link_header=substr($packet,16);
		$protocol_type_of_link_header=
			unpack("n",substr($packet,2+2+2+8,2));
	} else {
		# default is Ethernet link
		my $eth_obj=NetPacket::Ethernet->decode($packet);
		$data_stripped_link_header=$eth_obj->{data};
		$protocol_type_of_link_header=
			$eth_obj->{type};
	}
	if ($protocol_type_of_link_header != 0x0800) {
		warn (
		sprintf "uh? packet type of link header!=0x0800 value=%04X\n",
			$protocol_type_of_link_header);
	}
	my $ip_obj=NetPacket::IP->decode($data_stripped_link_header);
	if ($ip_obj->{proto} != 0x06) {
		warn (
		sprintf "uh? protocol is not 0x06 value=%02X\n",$ip_obj->{proto} );
	}
	my $tcp_obj=NetPacket::TCP->decode($ip_obj->{data});
#	print $ip_obj->{src_ip}.":".$tcp_obj->{src_port}."->"
#		.$ip_obj->{dest_ip}.":".$tcp_obj->{dest_port}."\n";
	my $payload=$tcp_obj->{data};
#        print "payload=".$payload."\n";
	if ($payload !~ /^(GET|POST)/i) {
		# abort
		return;
	}
	my $request= HTTP::Request->parse($payload);
	if (!defined $request->header('Host')) {
		return;
	}
	if (($request->header('Host') eq 'content.veoh.com') &&
		($request->url =~ /^\/flash/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /yourupload\.com/ ) &&
		($request->url =~ /\.flv\?/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /iask\.com/ ) &&
		($request->url =~ /flv$/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}	
	if (($request->header('Host') =~ /fc2\.com$/ ) &&
		($request->url =~ /^\/up\/flv\//)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /vimeo\.com$/ ) &&
		($request->url =~ /\.flv\?token=/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /4shared\.com$/ ) &&
		($request->url =~ /^\/img\//)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /anyap\.info:8080/ ) &&
		($request->url =~ /^\/sound/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /dailymotion\.com$/ ) &&
		(($request->url =~ /\.flv\?*/)||($request->url =~ /hq.flv/))) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /videoweed\.(es|com)$/ ) &&
		($request->url =~ /\.flv\?/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /\.novamov\.com$/ ) &&
		($request->url =~ /\.flv/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /\.novamov\.com$/ ) &&
		($request->url =~ /\.flv/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /^[0-9.]+/) &&
		(($request->url =~ /^\/dl\/.+\.flv/)||
		 ($request->url =~ /^\/..+\.mp4\/..+/) ||
		 ($request->url =~ /^\/..+\.mp4/))) {
		pcap_close($pcap);
		download_video_streams($request);
	} 
	if (($request->header('Host') =~ /\.xvideos\.com$/ ) &&
		($request->url =~ /\.flv\?/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /\.tokyo-tube\.com$/ ) &&
		($request->url =~ /=\.flv/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /daotube\.com$/ ) &&
		($request->url =~ /\.flv/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /photobucket\.com/ ) &&
		($request->url =~ /\.jpg/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /anitube\.com\.br$/ ) &&
		($request->url =~ /\.flv/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /cdn\.anitu\.be$/ ) &&
		($request->url =~ /\.(flv|mp4)/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /vid\.anitu\.be$/ ) &&
		($request->url =~ /\.(flv|mp4)/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /^stream.*\.igrooveshark\.com$/ ) &&
		($request->url =~ /stream\.php/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /auengine\.com$/ ) &&
		($request->url =~ /^\/videos/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /yucache\.net$/ ) &&
		($request->url =~ /\.flv\?/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /videofun\.me$/ ) &&
		($request->url =~ /\.flv\?/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
	if (($request->header('Host') =~ /youtube\.com$/ ) &&
		($request->url =~ /\/videoplayback\?/)) {
		pcap_close($pcap);
		download_video_streams($request);
	}
#	print "Host=".($request->header('Host'))." url=".($request->url)."\n";
}
sub download_video_streams {
	my ($request)=@_;
	my $fname=query_fname("found video link as".$request->uri.
		": filename=?");
	# never return
	my @command_lines=('curl','-L','-A',$request->header('User-Agent'));
	if ((defined $request->header('Cookie')) && ($request->header('Cookie') ne '')) {
		push(@command_lines,'-b',$request->header('Cookie'));
	}
	push(@command_lines,'-o',$fname);
	if (-e $fname) {
		push(@command_lines,'-C',(-s $fname));
	}
	push(@command_lines,'http://'.$request->header('Host').$request->uri);
	print join(" ",@command_lines)."\n";
	exec(@command_lines);
	exit (0);
}	
sub query_fname {
	my ($prompt)=@_;
	print $prompt;
	my $fname;
	while(<STDIN>) {
		chomp();
		if($_ !~ /^\s*$/) {
			$fname=$_;
			last;
		}
		print $prompt;
	}
	return $fname;
}
sub check_err {
	my ($err_str)=@_;
	if ($err_str ne '') {
		die "$err_str ,abort\n";
	}
}
__END__
