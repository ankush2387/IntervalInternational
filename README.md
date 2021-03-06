# Interval App for iOS - version 4 #

This repo contains the source code for the new Interval member-facing App, simply titled "Interval".  

## Who do I talk to'?' ##

* Ralph Fiol, AVP Digital Innovation, ralph.fiol@intervalintl.com
* Lloyd Hetherington, Project Manager
* Troy Gelinas, Business Analyst
* Luis Lopez, UI/UX Information Architect
* Alex Redondo, UI/UX Designer
* Frank Nogueiras, Project Lead, frank.nogueiras@intervalintl.com
* Aylwing Olivas, iOS Technical Lead, aylwing.olivas@intervalintl.com

## Project Resources ##

* Confluence: http://confluence/display/MEP/Mobile+Exchange+Project+Home
* JIRA iOS: http://jira/browse/MOBI
* JIRA Android: http://jira/browse/MOBA
* Sharepoint: http://ken-spsprd1/pmo/IProj/exchange_mobileapp/default.aspx

## CI/CD ##

* Upload to Installer

```shell
curl -H "X-InstallrAppToken: K2Q18sJvZilygz8kds0BonCJW1N215gD"  https://www.installrapp.com/apps.json \
  -F 'qqfile=@IntervalApp.ipa'
```

- Check the version in https://wwww.installrapp.com