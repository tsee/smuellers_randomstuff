#!perl
use strict;
use XSFun;
#my $reply = "+OK\r\n";
my $reply = join "\r\n", qw(
  *3
  :123
  $-1
  $9
  hhhhhhhhh
), "";
#$reply .= "\$100000\r\n" . ("x" x 100000) . "\r\n";

sub parse_elem {
  if ($_[0] =~ /\G\$(-?[0-9]+)\r\n/sgc) {
    return undef if $1 == -1;
    my $str = substr($_[0], pos($_[0]), $1);
    pos($_[0]) += $1+2;
    return $str;
  }
  elsif ($_[0] =~ /\G:(-?[0-9]+)\r\n/sgc) {
    return $1;
  }
  else {
    die;
  }
}
sub rparse {
  pos($_[0]) = 0;
  if ($_[0] =~ /\G\*(-?[0-9]+)\r\n/sgc) {
    my $nargs = $1;
    return undef
      if $nargs == -1;

    my @rv;
    foreach (1..$nargs) {
      push @rv, parse_elem($_[0]);
    }
    return \@rv;
  }
  elsif ($_[0] =~ /\G[:\$]/sgc) {
    pos($_[0])--;
    return [parse_elem($_[0])];
  }
  elsif ($_[0] =~ /\G([+-])/sgc) {
    my $rv = substr($_[0], ($1 eq '+' ? pos($_[0]) : pos($_[0])-1));
    $rv =~ s/\r\n$//;
    return $rv;
  }
  else { die }
}

#use Data::Dumper;
#warn Dumper(rparse($reply));
#warn Dumper(XSFun::redis_parse($reply));

use Benchmark qw(timethese);
timethese(-2, {
  xs => sub {my $x = XSFun::redis_parse($reply)},
  perl => sub {my $x = rparse($reply)},
});
