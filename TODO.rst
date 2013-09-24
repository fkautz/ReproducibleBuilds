TODO
====

Many of these improvements were suggested by Florian and Dan.

* Improve "rpm-compare" script.

  - We should compare the contents of ELF data sections as well.

  - We should check executable contents in the RPM headers, like %pre and %post
    scripts.

  - The rpm2cpio unpacking discards file permissions and the like, and doesn't
    cover ghost files. Porting this to Python using librpm can solve this and
    other problems.

  - It might also make sense to do an extremely low-level comparison of the RPM
    header, showing differences that cannot be explained in some way. This
    would catch the addition of new RPM tags with scripts, too. I'm not sure
    if this is possible with librpm. PyRPM might be of help there because it
    has tools to do such diffing which were used during its development.

* Support lookups in directories in "cache.

* Add "Visual Diff" support.
