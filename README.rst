Reproducible Builds
===================

It should be possible to reproduce every build of every package in Fedora
(strong, long-term goal).

It should be possible for the users to verify that the binary matches what the
source intended to produce, in an independent fashion. 

I want to be able to show that our binary was the result of our source code
from our compiler and nobody added anything along the way.

Can we (upstream / vendor) show that one of our rpms was built from the source
we ship?

We (the distribution provider) shouldn't be forced to say "Trust Us" to our
users at all.


Steps Involved
==============

* Recording the build environment (DONE)

  - Koji does this automatically :-)

* Re-producing the build environment (DONE)

  - Fetch all artefacts from upstream (optional)

    - Confirm the upstream binary is the one you have (trivial)

  - Retrieve "brootid" (buildrootID) corresponding to the NVR we want to test from
    Koji

    - Example task: http://koji.fedoraproject.org/koji/taskinfo?taskID=5447934

    - Example buildroot: http://koji.fedoraproject.org/koji/buildrootinfo?buildrootID=1701634     

    - We now have script(s) to do this.

  - Replicate this buildroot (DONE)
   
    - http://tinyurl.com/replicate-buildroot-using-mock

    - koji mock-config --buildroot=<buildrootID> name

    - e.g. koji mock-config --buildroot=1701634 UpEnv --topurl=http://kojipkgs.fedoraproject.org/ > UpEnv.cfg 

  - Create replica build environment using "Mock" (DONE)
   
* Do re-builds locally using mock (DONE)
  
* Verify new build against upstream (DONE, Steve's script works great)


Installation
============

::

  sudo yum install python-celery python-requests koji \
        python-urlgrabber python-setuptools python-billiard -y

::
   
   sudo yum install redis python-redis -y  # required for parallel processing

::

   sudo service redis start

::
  
   sudo chkconfig redis on

::

   # steal "group" information from upstream files

   python get-comps.py

   ln -s comps-f19.xml comps.xml  # use "comps-f20.xml" file or others if need be
   
Known Good Versions
===================

* Here are the software versions which are know to work 100%. Newer versions
  should be fine to.

  - python-celery-3.0.15-2.fc19.noarch

  - python-redis-2.7.2-2.fc19.noarch

  - redis-2.6.16-1.fc19.x86_64

  - python-urlgrabber-3.9.1-27.fc19.noarch

  - python-requests-1.2.3-5.fc19.noarch

  - python3-requests-1.2.3-5.fc19.noarch

  - python-setuptools-0.6.36-1.fc19.noarch

* Please note that older versions of ``python-celery`` package are known to be
  broken on Fedora 19.

Process Flow
============

* Initially, we have a NVR we want to verify (e.g. git-1.8.2.1-4.fc19).

  Let us assume that we have the corresponding RPM file(s) as well which are
  provided by the vendor and which we want to verify.

* First, obtain the SRPM corresponding to the target RPM file(s). 

* Next, we need to replicate the original buildroot.


  - Gather information about the buildroot corresponding to the NVR.

    ::
  
       python get-mock-info.py git-1.8.2.1-4.fc19

    This step will populate the RPM "cache" and generate
    ``git-1.8.2.1-4.fc19.env`` file which contains the buildroot replication
    information.

    Make sure you have ``celery worker --autoscale=10,0 -A tasks`` running to 
    do processing in the background.

  - Make repository which will be used by Mock.

    ::

       ./makerepo.sh git-1.8.2.1-4.fc19.env myrepo

    This command will create ``myrepo`` folder (which is our repository) by using
    the RPM "cache".

    This command will also create a ``myrepo.cfg`` file which is a Mock
    configuration file.

  - Build the SRPM using mock.

    ::

       mock -r myrepo --configdir=. --rebuild git-1.8.2.1-4.fc19.src.rpm

  - Compare upstream build with our local build.

    ::
    
       ./rpm-compare /upstream/git-1.8.2.1-4.fc19.x86_64.rpm \
            /var/lib/mock/myrepo/result/git-1.8.2.1-4.fc19.x86_64.rpm

Current State
=============

* Packages like git and john are 100% reproducible as far as code is concerned
  :-)

* We support "Recursive Verification". For example, if building "Z" requires
  installing "Y" RPM, then, once we have verified that Z is OK, we can ask our
  tool to verify "Y" too and so on.

Current Challenges
==================

See http://tinyurl.com/ReproducibleBuildsProblems

* python-epydoc will add timestamps to the HTML file it produces (needs
  FIXING).

* javadoc will add timestamps to the HTML file it produces (needs FIXING).
  

Links
=====

https://wiki.debian.org/ReproducibleBuilds

http://fedoraproject.org/wiki/Releases/FeatureBuildId#Unique_build_ID

http://blogs.kde.org/2013/06/19/really-source-code-software

https://blog.torproject.org/blog/deterministic-builds-part-one-cyberwar-and-global-compromise

https://trac.torproject.org/projects/tor/ticket/5837

https://trac.torproject.org/projects/tor/ticket/3688

http://bazaar.launchpad.net/~ubuntu-security/ubuntu-security-tools/trunk/files/head:/package-tools/


