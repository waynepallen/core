##Contributing Code

###Fork The Code

> we assume you already have a clone of  `https://github.com/opencrowbar/core`

  1. create a personal fork of the `https://github.com/opencrowbar/core`
    1. Fork the code if you want to be able to submit changes
    1. You may want to rename your fork in Github to something like 'crowbar-core' to make it easier to track.  We'll assume that you did that in these directions
  1. setup your git identity (one time only)
    1. `git config --global user.name "user.name"`
    1. `git config --global user.email "email.address"`
  1. add a personal remote: `git remote add personal `https://github.com/[yourgitnamehere]/[crowbar-core]`
  1. you can check your remotes using `git remote -v`

##To create a pull request

  1. make your change and commit it: `git commit -a -m "I cut and pasted this"`
  1. get the latest code from origin: `git fetch`
  1. sync your code into the trunk: `git rebase`
     1. you may have to merge changes using `git add [file]= and =git rebase --continue--`
  1. run and pass all the BDD tests, [[link missing]]
  1. push your change to your personal repo in a branch: `git push personal master:[my-pull-request-branch]`
  1. from your Github fork UI, create a pull request from my-pull-request-branch

## Developing with Chef Cookbooks

> _Strawman proposal: Up for Review_

### Crowbar and Berkshelf

For each of your workloads (core, openstack, hardware, etc.) Crowbar uses a centralized Berkshelf file for for all of your cookbooks. The Berksfile is in `opencrowbar/<workload>/chef/cookbooks/Berksfile`.  Crowbar ignores Berksfiles in individual cookbooks.

Berkshelf resolves cookbook dependencies by following the Berksfile instructions for local and remote dependent cookbooks.  It stores dependencies in the Berkshelf (path.)  If you're using a Chef Server, it can upload them to the Chef Server.  If you're using chef-solo or chef-client -x, it packages them on the filesystem  and delivers them to your nodes. 

We encourage you to clone from the OpenCrowbar github repos and submit pull requests.

### Developing Cookbooks

  * YOU MUST put your cookbook and all your cookbooks' dependencies in the centralized Berksfile for them to get picked up and used by the Chef Jig. 
  * You can use any of the normal sources to indicate the location of dependent cookbooks.
  * Put your custom and wrapper cookbooks in `opencrowbar/<workload>/chef/cookbooks/<my_cookbook>` 
  * The Berkshelf is located at /root/.berkshelf/  Do not edit it.  If you want to prune it of old and unnecessary versions of cookbooks, feel free to use `sudo berks shelf uninstall <cookbook> -v <version>`  The Chef Jig should replace any missing versions of cookbooks in the Berkshelf next time it runs.
  * You probably want the cookbooks you indicated as dependents to be available to you for reference while you're developing.  The following example will download them and put them in the right place for you.

```
cd <opencrowbar_root>/core/chef/
sudo berks install -b ./cookbooks/apache2/Berksfile -p ./newgoliath/deploy/
```

### Testing Cookbooks

TODO: Script this, possibly under 'tools'

   * create a test node (a kvm node is just fine)
   * add it to a deployment and add the node-role that your cookbook belongs to
   * kick off the annealer to deploy your cookbooks to a test node.

FUTURE:

   * Crowbar can help integrate your normal testing patterns.  We're considering `test-kitchen` integration.


##Edit Documentation

You do NOT need a local clone to update docs!  You can edit them right from your fork on Github.  Just make the changes and then create a pull request.  

We love DOCS changes.
