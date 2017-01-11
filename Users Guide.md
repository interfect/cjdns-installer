#Hello! Welcome to the meshnet!

If you're reading this, you probably just installed cjdns on your Windows machine! Congratulations!

If you chose the default installation options, with "public peers" enabled, you should already be connected to Hyperboria, the main cjdns network. Let's test it.

##Test cjdns connectivity
To test this, you can use the handy connectivity script test included with the installer. Just go to `Start -> All Programs -> CJDNS for Windows -> Test cjdns connectivity`. In the resulting window, if you see:

```
Pinging fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5 with 32 bytes of data:
Reply from fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5: time=159ms
Reply from fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5: time=206ms
Reply from fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5: time=224ms
...
```

Then you are on the meshnet, and everything is working properly. If you see:

```
Pinging fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5 with 32 bytes of data:
Request timed out.
Request timed out.
Request timed out.
...
```

Then cjdns is running, but you aren't connected to any peers that can send your traffic to the rest of Hyperboria (or irc.fc00.io is down and not responding to your pings). In this case, skip to [Add More Peers](#add-more-peers) below.

If you see:

```
Pinging fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5 with 32 bytes of data:
Destination net unreachable.
Destination net unreachable.
Destination net unreachable.
...
```

Then cjdns is not running correctly. It might just be stopped: try `Start -> All Programs -> CJDNS for Windows -> Start cjdns`, and see if it starts working.

If it doesn't, make sure the TAP driver is installed (it should get installed by default unless you unticked it), and make sure that you have a TAP adapter in `Control Panel\Network and Internet\Network Connections` (it should say TAP-Windows Adapter V9` on the third line). If that TAP adapter is named with non-Roman or other special characters, re-name it so that its name only contains English characters. Once that's all done, run `Start -> All Programs -> CJDNS for Windows -> Test cjdns configuration`, and see what cjdns has to say when it starts up. If it still doesn't work, take your cjdns output and head over to the [#projectmeshnet IRC on EFnet](http://chat.efnet.org:9090/?channels=#projectmeshnet) and ask for help.

##Add more peers

By default, the installer adds **public peers** to your cjdns configuration file. These are meshnet nodes on the Internet with owners that allow just anybody to connect to them, by publically posting the **peering credentials**. One set of credentials, for example, is published [here](http://transitiontech.ca/public).

In general, peering credentials look something like this:

```
"104.200.29.163:53053":{ // IP and port to connect to
  "password":"<REDACTED>", // A secret password to identify you
  "publicKey":"1941p5k8qqvj17vjrkb9z97wscvtgc1vp8pv1huk5120cu42ytt0.k", // A public key to identify the other end
},
```

Only one side of a given link needs peering credentials. The person on the other end just puts the password in their configuration file as an "authorized password".

###Make some Internet friends

The first step towards being a full citizen of Hyperboria is to move off of public peers and get your own real peers. You need to make a new friend on the meshnet and convince them to let you connect through them. The easiest way to do this is to ask on IRC, either on [EFNet's #projectmeshnet here](http://chat.efnet.org:9090/?channels=#projectmeshnet), or on #peering on the fc00 IRC network, available (if you are already connected to Hyperboria) at `fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5`. Unfortunately, this document can't really explain how to make Internet friends. Just be polite and respectful, and ready to tell people where you are so that they can see if they have any nodes near you.

###Configure cjdns to talk to your new friends

Once you have peering credentials in hand, you need to put them in your cjdns configuration file. To open it up, go to `Start -> All Programs -> CJDNS for Windows -> Configure cjdns`. Accept the UAC prompt, and a Notepad window should pop up, showing you your cjdns configuration file (which should be `C:\Program Files (x86)\cjdns\cjdroute.conf`). Note that this is a special administratively-empowered Notepad window; if you just open up cjdroute.conf and don't run your editor as administrator, you won't be allowed to save it. There should also be a command prompt window that's managing the editing process; don't close it.

Once you have your magic Notepad, find the *first* lines (unless you know what you're doing and are peering over IPv6) that look like this:

```
// Add connection credentials here to join the network
// Ask somebody who is already connected.
```

Right under that comment, add in your peering credentials that you received. If you got more than one set of credentials, make sure they are separated with commas between them. Once you're done, save your changes with `File -> Save` and close Notepad.

###Test your configuration

At this point, the command window should start doing exciting things, and another command window should appear. If your config file is correct, it should end with lines that look something like this:

```
1441945687 DEBUG Configurator.c:635 Cjdns started in the background
1441945687 DEBUG cjdroute2.c:675 Keeping cjdns client alive because --nobg was s
pecified on the command line
```

If it does look like that, you are good to go. Close that window (not the other one!) and cjdns should restart and apply your configuration, and try to connect to your new peer.

###Troubleshoot

If you see error messages or a prompt in that window, it means that cjdns didn't understand your configuration file. Close all the windows, and do `Start -> All Programs -> CJDNS for Windows -> Configure cjdns` again and look for where you may have made a mistake. Make sure all the quotes and braces are properly closed, and all the commas between things are between the things they need to be between. If all else fails, go ask for help from [EFNet's #projectmeshnet IRC channel](http://chat.efnet.org:9090/?channels=#projectmeshnet).

Remember, if you want to test if you can reach the meshnet, you can use `Start -> All Programs -> CJDNS for Windows -> Test cjdns configuration`. If you accidentally close the wrong window and cjdns isn't running, `Start -> All Programs -> CJDNS for Windows -> Start cjdns` should fix that right up.

##Administer your node

The cjdns installer provides several useful shortcuts, under `Start -> All Programs -> CJDNS for Windows`. They are:

* **Configure cjdns**: Edit the cjdns configuration file, and automatically test the configuration and restart cjdns.
* **Restart cjdns**: Restart cjdns, in case you edited the configuration file yourself or it is otherwise misbehaving.
* **Start cjdns**: Start up cjdns, if you have stopped it.
* **Stop cjdns**: Stop cjdns and leave the meshnet, until you restart either cjdns or your computer.
* **Test cjdns configuration**: Stop cjdns and re-start it in a command window, so you can see its output. Useful if you think it might be crashing or generating errors. When you close the foreground window, it gets re-started in the background.
* **Test cjdsn connectivity**: Sends messages to [socialno.de](http://socialno.de), which has address `fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5`. Lets you test whether you can talk to nodes on Hyperboria. Note that if socialno.de is down, this tool will not be able to talk to it even though you might be correctly connected and able to reach other meshnet nodes.

##Fix IPv6 DNS Problems

By default, the CJDNS for Windows installer installs a version of [Kubuxu's DNS hack](http://student.agh.edu.pl/~ksztand/2015/12/dns-fix-for-windows/) which should allow browsing to work out of the box in Firefox, even with no Internet IPv6 connectivity. **If Chrome is not working, try Firefox!**

If you don't have [Internet IPv6 connectivity](http://test-ipv6.com/), you may have some issues using the meshnet, because your browser or OS may try to second-guess you. For example, if Chrome doesn't see you as having IPv6 access to the Internet, it can refuse to even try to connect to domain names that resolve to IPv6 addresses. Since the meshnet is an IPv6-only network, and meshnet web sites like http://socialno.de or http://hub.hyperboria.net/ point their DNS names to their IPv6 addresses, this can result in you not being able to reach any meshnet sites by name in your browser.

If you think that may be your problem, try accessing Hyperboria.name via `http://[fcfd:9511:69cc:a05e:4eb2:ed20:c6a0:52e3]/`. if that works but `http://hyperboria.name` fails, you have a DNS problem.

If you have this problem, try a different browser, or try reconfiguring your browser's IPv6 settings. If that doesn't work, try to get IPv6 Internet access from your ISP, or through a tunnel provider like [Hurricane Electric](https://tunnelbroker.net/), or try setting a static IPv6 address on your (non-TAP) network interfece.

##Explore the Meshnet

* Visit cool meshnet sites:
    * [Hyperboria.name e-mail service](http://hyperboria.name) or `http://[fcfd:9511:69cc:a05e:4eb2:ed20:c6a0:52e3]/` by IPv6 address
    * [fc00.org network map](http://h.fc00.org) or [by Internet](http://fc00.org)
    
* Trick out your browser:
    * [IPvFoo Hyperboria Edition](https://chrome.google.com/webstore/detail/ipvfoo-hyperboria-edition/klnbkhdpiindiigfpbblonnajhcagpmk?hl=en) for Chrome lets you know if you are on an IPv4 Internet, IPv6 Internet, or Hyperboria web site.
    * [IPvFox](https://addons.mozilla.org/en-US/firefox/addon/ipvfox/) for Firefox just tells you if your web page is IPv4 or IPv6, but if you click on the 6 and it starts with "fc", you're on Hyperboria!
    
* Connect to IRC:
    * IPv6 Address: fcec:ae97:8902:d810:6c92:ec67:efb2:3ec5 or irc.fc00.io
    * Port: 6667
    * Client: any supporting IPv6, like [this one](http://www.adiirc.com/) or even [this one](http://www.mirc.com/).
    
* Connect to DC++:
    * URL: [adc://dc.on.hyperboria.name:1511](adc://dc.on.hyperboria.name:1511)
    * Client: Any that supports IPv6, like [this one](http://dcplusplus.sourceforge.net/) or [this one](http://www.airdcpp.net/)
    * Remember to obey all relavent copyright laws! You are not anonymous on the meshnet; any of your peers can tell people who you are!
    
* Lock down your firewall:
    * If you're running cjdns, you have an IPv6 address on the meshnet. Like with Internet IPv6, your home router doesn't prevent random people from sending unsolicited messages to your computer.
    * Make sure to visit the Windows firewall settings (type "Windows Firewall with Advanced Security" in the Start menu) and create rules to block IPv6 or meshnet access to any servers you are running that you don't want visible to the whole meshnet.
    
* Run your own meshnet web site:
    * Come up with an idea
    * Install a [web server](http://www.aprelium.com/abyssws/)
    * Start coding!

    
