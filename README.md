A simple client server app written in swift for linux. 

This project serves no purpose other than to have a bit of everything in it: some file handling, string parsing, networking, database, concurrency, marshalling to json, basic authentication etc, while trying out swift.

The server reads cpu and kernel status from /proc/stat and /proc/cpuinfo and exposes this information with a simple REST service over https

Steps to install
================

Download a build of swift from Apple:

https://swift.org/download/#linux

Install Clang and ICU

```
sudo apt-get install clang libicu-dev

echo "deb [trusted=yes] http://apt.zewo.io/deb ./" | sudo tee --append /etc/apt/sources.list
sudo apt-get update
sudo apt-get install zewo
```


DB Schema
=========

```create table cpuinfo ( 
	id			serial primary key,
	time		timestamp without time zone not null,
	userland	numeric(4,1) not null, 
	nice		numeric(4,1) not null, 
	system		numeric(4,1) not null, 
	idle		numeric(4,1) not null, 
	iowait		numeric(4,1) not null, 
	irq			numeric(4,1) not null, 
	softirq		numeric(4,1) not null, 
	steal		numeric(4,1) not null, 
	freq		numeric(4,1) not null, 
	temperature numeric(4,1) not null
);

create index index_time on cpuinfo(time);```


TODO
====

- HTTPS (Broken as of March 2016)
- Authentication password hashing

Links
=====

http://docs.zewo.io/
