# Quotopia
[![Build Status](https://travis-ci.org/scalableinternetservices/Quotopia.svg?branch=master)](https://travis-ci.org/scalableinternetservices/quotopia)

## Project Description
Quotopia is a quote-sharing application with reddit-style voting, commenting, favoriting and Twitter integration.

## Pivotal Tracker Link
[Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1321098)


## Team Quotopia
| ![Roger Chen](https://media.licdn.com/media/p/7/005/03f/3b1/0ea3675.jpg) | ![Steven Collison](https://media.licdn.com/media/p/5/005/06c/1d1/232135c.jpg) | ![Synthia Ling](https://media.licdn.com/media/p/5/005/08a/305/0c0cbe8.jpg) | ![Christina Yang](https://media.licdn.com/media/p/5/005/02e/23b/092dbfb.jpg) | ![Julian Yang](https://scontent.xx.fbcdn.net/hphotos-xfa1/v/t1.0-9/10557430_10152132051002273_8202719108063151833_n.jpg?oh=ddc24df8869761be006c8facbe9f7c02&oe=559D0F6C)
| :------------: | :------------: | :------------: | :------------: | :------------: | 
| Roger Chen | Steven Collison | Synthia Ling | Christina Yang | Julian Yang
| [@rchen93](https://github.com/rchen93) | [@raycoll](https://github.com/raycoll) | [@synthling](https://github.com/synthling) | [@christinay412](https://github.com/christinay412) | [@julianyang](https://github.com/julian-yang)

## Installation
First, install Ruby on Rails: [https://gorails.com/setup/](https://gorails.com/setup/)

The Ruby version we used to develop is 2.2.x.

The Rails version we used to develop is 4.2.1.

To ensure all necessary dependencies from the Gemfile are available to the application, run:

```
$ bundle install
```

## Usage
To begin the application locally, run:

```
$ rake db:migrate
$ rails server
```

To use the seed data (~20k rows), run:

```
$ rake db:seed
```
