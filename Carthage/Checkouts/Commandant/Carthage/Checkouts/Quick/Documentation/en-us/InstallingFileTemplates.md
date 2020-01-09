# Installing Quick File Templates

The Quick repository includes file templates for both Swift and
Objective-C specs.

## Alcatraz

Quick templates can be installed via [Alcatraz](https://github.com/supermarin/Alcatraz),
a package manager for Xcode. Just search for the templates from the
Package Manager window.

![](http://f.cl.ly/items/3T3q0G1j0b2t1V0M0T04/Screen%20Shot%202014-06-27%20at%202.01.10%20PM.png)

## Manually via the Rakefile

To manually install the templates, just clone the repository and
run the `templates:install` rake task:

```sh
$ git clone git@github.com:Quick/Quick.git
$ rake templates:install
```

Uninstalling is easy, too:

```sh
$ rake templates:uninstall
```
