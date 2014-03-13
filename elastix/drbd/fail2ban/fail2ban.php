#!/usr/bin/php
<?php
/*
  vim: set expandtab tabstop=4 softtabstop=4 shiftwidth=4:
  Codificación: UTF-8
  +----------------------------------------------------------------------+
  | Elastix version 2.0                                                  |
  | http://www.elastix.org                                               |
  +----------------------------------------------------------------------+
  | Copyright (c) 2006 Palosanto Solutions S. A.                         |
  +----------------------------------------------------------------------+
  | Cdla. Nueva Kennedy Calle E 222 y 9na. Este                          |
  | Telfs. 2283-268, 2294-440, 2284-356                                  |
  | Guayaquil - Ecuador                                                  |
  | http://www.palosanto.com                                             |
  +----------------------------------------------------------------------+
  | The contents of this file are subject to the General Public License  |
  | (GPL) Version 2 (the "License"); you may not use this file except in |
  | compliance with the License. You may obtain a copy of the License at |
  | http://www.opensource.org/licenses/gpl-license.php                   |
  |                                                                      |
  | Software distributed under the License is distributed on an "AS IS"  |
  | basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See  |
  | the License for the specific language governing rights and           |
  | limitations under the License.                                       |
  +----------------------------------------------------------------------+
  | The Original Code is: Elastix Open Source.                           |
  | The Initial Developer of the Original Code is PaloSanto Solutions    |
  +----------------------------------------------------------------------+
  $Id: fail2ban.php,v 1.1 2013-06-10 07:25:22 Nikita Rukavkov admin@voip-lab.ru Exp $
*/
require_once 'Console/Getopt.php';

global $sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT;

global $debug;

//$debug = true;

load_default_timezone();
load_default_ports();


// Parse command-line options
$opt = Console_Getopt::getopt($argv, '', array(
    'dumpiptables', // Dump IPTABLES configuration
    'checkjails',
    'removefromiptables',
    'checkservice',
    'movelicense',
    'config',   // Configurate Fail2Ban options
    'start',    // Start Fail2Ban service and mark as autostart
    'stop',     // Stop Fail2Ban service and remove from autostart
    'ziplogs',
    
    // Fail2Ban configuration options
    'ip=',
    'table=',
    'mail=',    // Mail to report
    'count=',      // Count of try to auth
    'bantime=',  // Time to ban
    'exceptions=', // Exceptions to auth 
    'monitor=', // Check services every mins
    'filelic=',
    'web', 
    'asterisk', 
    'ssh',
    'proftpd',
    'vsftpd',
));

if (PEAR::isError($opt)) error_exit($opt->getMessage()."\n");

validateOptions($opt);
foreach ($opt[0] as $option) switch ($option[0]) {
    case '--dumpiptables':
	checklic();
	exit(action_dumpiptables() ? 0 : 1);
    case '--checkjails':
	checklic();
	exit (action_checkjails($opt) ? 0 : 1);
    case '--checkservice':
	checklic();
	exit(action_checkservice($opt) ? 0 : 1);
    case '--removefromiptables':
    	checklic();
	exit(action_removefromiptables($opt) ? 0 : 1);
    case '--movelicense':
	exit(action_movelicense($opt) ? 0 : 1);
    case '--config':
    	checklic();
	exit(action_configuration($opt) ? 0 : 1);
    case '--start':
    	checklic();
	exit(action_start($opt) ? 0 : 1);
    case '--stop':
    	checklic();
	exit(action_stop($opt) ? 0 : 1);
    case '--ziplogs':
    	checklic();
	exit(action_ziplogs() ? 0 : 1);
}

error_exit("No action specified (--config or --start or --stop)\n");

function checklic()
{
/*    if (!file_exists('/var/www/html/modules/anti_hacker/configs/anti-hacker.lic')) 
	error_exit("Unregistered version. Please purchase Anti-Hacker Addon into Elastix Store. Return to Addons Page and press BUY Button.\n",2);
    else
    {
	if(file_exists('/etc/elastix.key'))
	{
	    if(mc_encrypt()!=trim(file_get_contents('/var/www/html/modules/anti_hacker/configs/anti-hacker.lic')))
		error_exit("Unregistered version. Please upload correct License File \n",2);
	}
	else
    	    error_exit("Unregistered version. Please upload correct License File and repair Elastix License Key /etc/elastix.key \n",2);
    }
  */
  sleep(1);  
}

function error_exit($sMsg, $errorcode = 1)
{
    fwrite(STDERR, $sMsg);
    exit($errorcode);
}

function load_default_timezone()
{
    $sDefaultTimezone = @date_default_timezone_get();
    if ($sDefaultTimezone == 'UTC') {
        $sDefaultTimezone = 'America/New_York';
        if (file_exists('/etc/sysconfig/clock')) {
            foreach (file('/etc/sysconfig/clock') as $s) {
                $regs = NULL;
                if (preg_match('/^ZONE\s*=\s*"(.+)"/', $s, $regs)) {
                    $sDefaultTimezone = $regs[1];
                }
            }
        }
    }
    date_default_timezone_set($sDefaultTimezone);
}

// Parse and validate known command-line options
function validateOptions($opt)
{
    foreach ($opt[0] as $option) switch ($option[0]) {
        case '--mail':
    	    if (!preg_match("/^[^@]*@[^@]*\.[^@]*$/", $option[1]))
    		error_exit('Option '.$option[0].": Invalid Email address\n");
    	    break;
        case '--bantime':
    	    if (!ctype_digit($option[1]))
        	error_exit('Option '.$option[0].": Invalid Ban time\n");
    	    break;
    	case '--exceptions':
    	    if($option[1]!=''){
    		$tExceptions=explode(",", $option[1]);
    		foreach($tExceptions as $ip){
		    $regs = NULL;
    		    if (!preg_match('/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/', $ip, $regs)){
			if (!preg_match('/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/(\d{1,3})$/', $ip, $regs))
			    if(!preg_match('/^(([[:alnum:]-]+)\.)+([[:alnum:]])+$/', $ip,$regs))
				error_exit('Option '.$option[0].": Invalid Exceptions list. Allows only IP-addresses, Networks an Domain names. Example: <b>192.168.1.0/24,8.8.8.8,trusted.domain.com</b>\n");
    		    }
    		    else{
    			for ($i = 1; $i <= 4; $i++) if ($regs[$i] > 255){
			    error_exit('Option '.$option[0].": Invalid Exceptions list\n");
    		        }
    		    }
		}
	    }
    }
}

// Dump configuration fail2ban
function action_dumpiptables()
{
    $ret = split("\n", `/sbin/iptables-save | grep "^-A fail2ban-"`);
    foreach($ret as $n => $rstr) { 
	echo $rstr."\n";
    }
}

function bugfix_fail2ban($sTable)
{
    global $sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT;

    $bExito = TRUE;
    
    if($sTable != '')
    {
	exec("/sbin/iptables -F fail2ban-$sTable",$output,$ret);
	exec("/sbin/iptables -X fail2ban-$sTable",$output,$ret);
	exec("/sbin/iptables -N fail2ban-$sTable",$output,$ret);
        if($ret != 0) $bExito = FALSE;
        
	exec("/sbin/iptables -A fail2ban-$sTable -j RETURN",$output,$ret);
        if($ret != 0) $bExito = FALSE;

	switch($sTable)
	{
	    case 'vsftpd':
		exec("/sbin/iptables -D INPUT -p tcp -m multiport --dport $vsftpdPORT -j fail2ban-$sTable",$output,$ret);
	        exec("/sbin/iptables -I INPUT -p tcp -m multiport --dport $vsftpdPORT -j fail2ban-$sTable",$output,$ret);
	        if($ret != 0) $bExito = FALSE;
		break;
	    case 'ssh':
		exec("/sbin/iptables -D INPUT -p tcp -m multiport --dport $sshPORT -j fail2ban-$sTable",$output,$ret);
		exec("/sbin/iptables -I INPUT -p tcp -m multiport --dport $sshPORT -j fail2ban-$sTable",$output,$ret);
		if($ret != 0) $bExito = FALSE;
		break;
	    case 'asterisk':
		exec("/sbin/iptables -D INPUT -p udp -m multiport --dport $asteriskPORT -j fail2ban-$sTable",$output,$ret);
		exec("/sbin/iptables -I INPUT -p udp -m multiport --dport $asteriskPORT -j fail2ban-$sTable",$output,$ret);
		if($ret != 0) $bExito = FALSE;
		break;
	    case 'https':
		exec("/sbin/iptables -D INPUT -p tcp -m multiport --dport $httpsPORT -j fail2ban-$sTable",$output,$ret);
		exec("/sbin/iptables -I INPUT -p tcp -m multiport --dport $httpsPORT -j fail2ban-$sTable",$output,$ret);
		if($ret != 0) $bExito = FALSE;
		break;
	}
    }
    else $bExito = FALSE;
    
    return $bExito;
}

function action_checkjails($opt)
{
    global $debug;
    $bExito = TRUE;

    foreach ($opt[0] as $option) switch ($option[0]) {
	case '--table':
    	    $sTable = $option[1];
    	    break;
    }
    
    if($sTable != '')
	$bExito = checkJails($sTable);
    else 
	$bExito = FALSE;
    
    if($debug) echo "FUNCTION action_checkjails($sTable) $bExito\n";
    
    return $bExito;
}

function action_checkservice($opt)
{
    global $debug,$sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT;
    $bExito = TRUE;
    $sTable = NULL;
    
    foreach ($opt[0] as $option) switch ($option[0]) {
	case '--table':
    	    $sTable = $option[1];
    	    break;
    }

    $bExito = check_process($sTable);

    switch($sTable)
    {
	case 'httpd':
	    echo $httpsPORT;
	    break;
	case 'sshd':
	    echo $sshPORT;
	    break;
	case 'asterisk':
	    echo $asteriskPORT;
	    break;
	case 'vsftpd':
	    echo $vsftpdPORT;
	    break;
	default:
	    echo 'error';
    }

    if($debug) echo "FUNCTION action_checkservice($sTable) $bExito\n";
    return $bExito;
}

function action_ziplogs()
{
    $bExito = TRUE;

    `rm -f /tmp/antihacker_logs.zip`;
    `/usr/bin/zip -j /tmp/antihacker_logs.zip /var/log/fail2ban*`;
    
    return $bExito;
}



function checkJails($sTable)
{
    global $debug,$sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT;
    $checkPort = $output = $ret = NULL;
    $bExito = TRUE;
    
    //Chain checking fail2ban-ssh,fail2ban-vsftpd....
    
    
    exec("/bin/egrep 'name=$sTable, port' /etc/fail2ban/jail.conf | cut -d'\"' -f2",$output,$ret);

    if($debug) print_r($output);
        
    $checkPort=trim($output[0]);
    
    switch($sTable)
    {
        case 'ssh':
	    if($sshPORT != '')
    		$bExito = ($checkPort != $sshPORT ? FALSE : TRUE);
    	    break;
    	case 'asterisk':
    	    if($asteriskPORT != '')
    	        $bExito = ($checkPort != $asteriskPORT ? FALSE : TRUE);
    	    break;
    	case 'vsftpd':
    	    if($vsftpdPORT != '')
    	        $bExito = ($checkPort != $vsftpdPORT ? FALSE : TRUE);
    	    break;
    	case 'https':
    	    if($httpsPORT != '')
    	    {
    	        $bExito = ($checkPort != $httpsPORT ? FALSE : TRUE);
    	    }
    	    break;
    }

    if($checkPort!='')
    {
        $ret = split("\n", `/sbin/iptables-save | grep "^-A fail2ban-$sTable -j RETURN"`);
        if(count($ret) < 2 ) 
        {
    	    $bExito = FALSE;
    	}
        //Chain checking INPUT
        $ret = split("\n", `/sbin/iptables-save | grep fail2ban-$sTable | grep -F ' $checkPort '`);
        
        if(count($ret) < 2) 
        {
    	    $bExito = FALSE;
    	}
        
    }
    else
    {

        $bExito = FALSE;
    }
    
    if($debug) echo "checkjails $sTable $bExito\n";
    
    return $bExito;
}

function action_removefromiptables($opt)
{
    $bExito = TRUE;

    $sIP = $sTable = NULL;

    foreach ($opt[0] as $option) switch ($option[0]) {
	case '--ip':
    	    $sIP = $option[1];
    	    break;
	case '--table':
    	    $sTable = $option[1];
    	    break;
    }
    `/sbin/iptables -D $sTable -s $sIP -j DROP`;
}

function action_movelicense($opt)
{
    $bExito = TRUE;

    foreach ($opt[0] as $option) switch ($option[0]) {
	case '--filelic':
    	    $filelic = $option[1];
    	    break;
    }
    
    if(file_exists($filelic))
	`/bin/mv $filelic /var/www/html/modules/anti_hacker/configs/anti-hacker.lic`;
}


function action_configuration($opt)
{
    $bExito = TRUE;

    $sMail = $sCount = $sBantime = $sExceptions = $sMonitor = NULL;
    $sAsterisk = $sWeb = $sProftpd = $sVsftpd = $sSsh = false;
    foreach ($opt[0] as $option) switch ($option[0]) {
	case '--mail':
    	    $sMail = $option[1];
    	    break;
	case '--count':
    	    $sCount = $option[1];
    	    break;
	case '--bantime':
    	    $sBantime = $option[1];
    	    break;
	case '--monitor':
    	    $sMonitor = $option[1];
    	    break;
	case '--exceptions':
    	    $tExceptions=explode(",", $option[1]);
    	    foreach($tExceptions as $ip)
    		$sExceptions .= "$ip ";
    	    break;
    	case '--asterisk':
    	    $sAsterisk = true;
    	    break;
    	case '--vsftpd':
    	    $sVsftpd = true;
    	    break;
    	case '--proftpd':
    	    $sProftpd = true;
    	    break;
    	case '--web':
    	    $sWeb = true;
    	    break;
    	case '--ssh':
    	    $sSsh = true;
    	    break;    
	}
    // Check required parameters
    if ($bExito && is_null($sMail)) {
        $bExito = FALSE;
        fprintf(STDERR, "ERR: mail to report must be specified\n");
    }
    if ($bExito && is_null($sCount)) {
        $bExito = FALSE;
        fprintf(STDERR, "ERR: count must be specified\n");
    }
    if ($bExito && is_null($sBantime)) {
        $bExito = FALSE;
        fprintf(STDERR, "ERR: ban time must be specified\n");
    }
    if ($bExito) {
        $bExito = configureFail2Ban($sMail, $sCount, $sBantime,$sMonitor, $sExceptions, $sAsterisk, $sWeb, $sProftpd, $sVsftpd, $sSsh);
    }
    
    return $bExito;
}


function genJailConf($sName, $sMail, $sCount, $sBantime, $sExceptions = NULL,$sLogPath, $sPort,$sProto,$sFilter)
{
    $toWrite="[$sName-iptables]\n";
    $toWrite.="enabled  = true\n";
    $toWrite.="filter   = $sFilter\n";
    $toWrite.="action   = iptables-multiport[name=$sName, port=\"$sPort\", protocol=$sProto]\n";
    $toWrite.="           sendmail-whois[name=$sName, dest=$sMail]\n";
    $toWrite.="logpath  = $sLogPath\n";
    $toWrite.="maxretry = ".$sCount."\n";
    $toWrite.="ignoreip = ".$sExceptions."\n";
    $toWrite.="bantime = ".$sBantime."\n\n";
    return $toWrite;
}


// Write out Fail2Ban configuration from requested parameters. Return TRUE on success
// sCfg is array services for protection
function configureFail2Ban($sMail, $sCount, $sBantime, $sMonitor, $sExceptions = NULL, $sAsterisk, $sWeb, $sProftpd, $sVsftpd, $sSsh)
{
    global $sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT;
    
    $bExito=TRUE;
    
    if($sExceptions != NULL)
    {
	$wsExceptions = "";

	$tExceptions=explode(" ", $sExceptions);
	foreach($tExceptions as $ip) 
	    if($ip!="") $wsExceptions .= "$ip,";

	$wsExceptions=substr($wsExceptions,0,-1);
    }
    $filename_jail = "/etc/fail2ban/jail.conf";
    $filename_fail2ban = "/etc/fail2ban/fail2ban.conf";
    $filename_logrotate = "/etc/logrotate.d/fail2ban";
    $filename_cron = "/etc/cron.d/antihacker";
    $filename_settings = "/var/www/html/modules/anti_hacker/configs/settings.conf";

    //WRITE LOGROTATE CONFIG
    $fflr = fopen($filename_logrotate, "w+");
    fwrite($fflr, "/var/log/fail2ban.log {\n");
    fwrite($fflr, "\tdaily\n");
    fwrite($fflr, "\trotate 7\n");
    fwrite($fflr, "\tmissingok\n");
    fwrite($fflr, "\tnotifempty\n");
    fwrite($fflr, "\tcreate 0600 root root\n}");
    fclose($fflr);
    
    //WRITE FAIL2BAN CONFIG
    $ff2b = fopen($filename_fail2ban, "w+");
    fwrite($ff2b, "[Definition]\n");
    fwrite($ff2b, "loglevel = 3\n");
    fwrite($ff2b, "logtarget = /var/log/fail2ban.log\n");
    fwrite($ff2b, "socket = /var/run/fail2ban/fail2ban.sock\n");
    fclose($ff2b);
    
    //WRITE ANTIHACKER SETTINGS
    $fs = fopen($filename_settings, "w+");
    fwrite($fs, "target = $sMail\n");
    fwrite($fs, "count = ".$sCount."\n");
    fwrite($fs, "bantime = ".$sBantime."\n");
    fwrite($fs, "websecure = ".($sWeb ? "on":"off")."\n");
    fwrite($fs, "asterisksecure = ".($sAsterisk ? "on":"off")."\n");
    fwrite($fs, "sshsecure = ".($sSsh ? "on":"off")."\n");
    fwrite($fs, "vsftpdsecure = ".($sVsftpd ? "on":"off")."\n");
    fwrite($fs, "exceptions = ".$wsExceptions."\n");
    fwrite($fs, "monitor = ".$sMonitor."\n");
    fclose($fs);
    
    //WRITE MONITORING
    $cron_exec_time = NULL;
    switch($sMonitor)
    {
	case "5":
	    $cron_exec_time = "*/5 * * * *";
	    break;
	case "30":
	    $cron_exec_time = "00,30 * * * *";
	    break;
	case "60":
	    $cron_exec_time = "00 * * * *";
	    break;
	case "180":
	    $cron_exec_time = "00 */3 * * *";
	    break;	
	case "360":
	    $cron_exec_time = "00 */6 * * *";
	    break;	
	case "720":
	    $cron_exec_time = "00 */12 * * *";
	    break;	
	case "1440":
	    $cron_exec_time = "00 00 * * *";
	    break;	
    }
    $fc = fopen($filename_cron, "w+");
    if($cron_exec_time != NULL)
	fwrite($fc, $cron_exec_time." root /usr/bin/php -q /var/www/html/modules/anti_hacker/libs/aChecker.php\n");
    else
	fwrite($fc, "");
    fclose($fc);
    
    
    //WRITE FAIL2BAN JAILS CONFIG
    if ( is_writeable($filename_jail) )
    {
	//Write defaults
	$fh = fopen($filename_jail, "w+");
	fwrite($fh, "[DEFAULT]\n");
	fwrite($fh, "bantime  = 600\n");
	fwrite($fh, "findtime  = 600\n");
	fwrite($fh, "maxretry = 3\n");
	fwrite($fh, "backend = auto\n\n");
	
	if($sAsterisk)
	{
	    fwrite($fh, genJailConf("asterisk",$sMail,$sCount,$sBantime,$sExceptions,"/var/log/asterisk/full",$asteriskPORT,"udp","asterisk"));
//	    fwrite($fh, genJailConf("Asterisk/tcp",$sMail,$sCount,$sBantime,$sExceptions,"/var/log/asterisk/full",$asteriskPORT,"tcp","asterisk"));
	}
	if($sWeb)
	{
	    echo "WRITE CONFIG. PORT: ".$httpsPORT;
	//    fwrite($fh, genJailConf("http",$sMail,$sCount,$sBantime,$sExceptions,"/var/log/elastix/audit.log",$httpsPORT,"tcp","httpd"));	    
	    fwrite($fh, genJailConf("https",$sMail,$sCount,$sBantime,$sExceptions,"/var/log/elastix/audit.log",$httpsPORT,"tcp","httpd"));
	}
	if($sSsh)
	    fwrite($fh, genJailConf("ssh",$sMail,$sCount,$sBantime,$sExceptions,"/var/log/secure",$sshPORT,"tcp","sshd"));	    
	if($sVsftpd)
	    fwrite($fh, genJailConf("vsftpd",$sMail,$sCount,$sBantime,$sExceptions,"/var/log/secure",$vsftpdPORT,"tcp","vsftpd"));  
	
	fclose($fh);
	
	//Restart fail2ban and apply bugfix
	if(is_fail2ban_active())
	{
	    `/sbin/service fail2ban restart`;
	    sleep(2);
	    if($sAsterisk)
		if(checkJails('asterisk') == FALSE) bugfix_fail2ban('asterisk');
	    if($sWeb)
	        if(checkJails('https') == FALSE) bugfix_fail2ban('https');
	    if($sSsh)
		if(checkJails('ssh') == FALSE) bugfix_fail2ban('ssh');
	    if($sVsftpd)
		if(checkJails('vsftpd') == FALSE) bugfix_fail2ban('vsftpd');
	}	    
    }
    else $bExito=FALSE;
    return $bExito;
}

// Starts FAIL2BAN and marks it for autostart. Returns TRUE on success.
function action_start($opt)
{
    //Check fail2ban/filter.d/asterisk.conf
    
    $filter_path="/etc/fail2ban/filter.d/asterisk.conf";
    if(!file_exists($filter_path))
	copy("/var/www/html/modules/fail2ban/configs/asterisk.conf",$filter_path); 
    
    $output = $ret = NULL;
    if (!is_fail2ban_active()) {
	exec('/sbin/service fail2ban start', $output, $ret);
	if ($ret != 0) return FALSE;
    }
    exec('/sbin/chkconfig --level 235 fail2ban on', $output, $ret);
    return ($ret == 0);
}

// Stops FAIL2BAN and removes it from autostart. Returns TRUE on success
function action_stop($opt)
{
    $output = $ret = NULL;
    if (is_fail2ban_active()) {
        exec('/sbin/service fail2ban stop', $output, $ret);
        if ($ret != 0) return FALSE;
    }
    exec('/sbin/chkconfig --level 235 fail2ban off', $output, $ret);
    return ($ret == 0);
}

// Check whether DHCP is running
function is_fail2ban_active()
{
    $output = $ret = NULL;
    exec('/sbin/service fail2ban status > /dev/null 2>&1', $output, $ret);
    return ($ret == 0);
}

function mc_encrypt(){
    $encrypt=file_get_contents('/etc/elastix.key');
    $encrypt = serialize($encrypt);
    $encoded = base64_encode($encrypt);
    return $encoded;
}

function load_default_ports()
{
    global $sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT,$debug;
    
    $sshPORT = "22";
    $asteriskPORT = "5060";
    $vsftpdPORT = "21";
    $httpsPORT = "80,443";
    
    // SSH PORT
    if(check_process('sshd'))
    {
        $output = $ret = $tmpPORT= NULL;
	exec("/usr/sbin/ss -lpn | grep sshd | awk '{print $3}' | cut -d':' -f2", $output, $ret);
	if($ret == 0)
	{
	    foreach(array_unique($output) as $port) 
		if(is_numeric($port))	
		    $tmpPORT .= $port.",";
	    if($tmpPORT != '') $sshPORT = substr($tmpPORT,0,-1);
	}
    }
    
    // ASTERISK PORT
    if(check_process('asterisk'))
    {
	$asteriskPORT = 5060;
    }

    // FTP PORT
    if(check_process('vsftpd'))
    {
	$output = $ret = $tmpPORT= NULL;
	exec("/usr/sbin/ss -lpn | grep vsftpd | awk '{print $3}' | cut -d':' -f2", $output, $ret);
	if($ret == 0)
	{
	    foreach(array_unique($output) as $port) 
		if(is_numeric($port))	
		    $tmpPORT .= $port.",";
	    if($tmpPORT != '') $vsftpdPORT = substr($tmpPORT,0,-1);
	}
    }

    // HTTP PORT
    if(check_process('httpd'))
    {
	$output = $ret = $tmpPORT = NULL;
	exec("/usr/sbin/ss -lpn | grep httpd | awk '{print $3}' | cut -d':' -f2", $output, $ret);
	if($ret == 0)
	{
	    foreach(array_unique($output) as $port) 
		if(is_numeric($port))	
		    $tmpPORT .= $port.",";
	    if($tmpPORT != '') $httpsPORT = substr($tmpPORT,0,-1);
	}
    }
    if($debug) echo "PORTS DETECTED: $sshPORT,$asteriskPORT,$vsftpdPORT,$httpsPORT\n";
    
}


function check_process($process)
{
    global $debug;
    $output = $ret = NULL;
    if($process != '')
    {
	//if($debug) echo "Process $process running check:".file_exists("/var/lock/subsys/$process")."\n";
	exec("/sbin/pidof -s $process",$pid);
	return ($pid[0] != '' ? TRUE : FALSE);
    }
    else return FALSE;
}
                                          

?>
