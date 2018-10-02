# Quick 파일 템플릿 설치하기

Quick 레포지토리는 Swift와 Objective-C 사양 모두를 위한 파일 템플릿들을 포함하고 있습니다.

## Alcatraz

Quick 템플릿은 Xcode 용 패키지 관리자인 [Alcatraz](https://github.com/supermarin/Alcatraz)를 통해 설치할 수 있습니다. 패키지 매니저 창에서 단지 템플릿을 검색만 하면 됩니다.


![](http://f.cl.ly/items/3T3q0G1j0b2t1V0M0T04/Screen%20Shot%202014-06-27%20at%202.01.10%20PM.png)

## Rakefile를 통해 수동으로

템플릿을 수동으로 설치하려면, 레퍼짓토리를 clone 한 뒤 `templates:install` 명령어를 rake 작업으로 실행하세요.

```sh
$ git clone git@github.com:Quick/Quick.git
$ rake templates:install
```

삭제도 간단합니다 :

```sh
$ rake templates:uninstall
```
