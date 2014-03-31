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

### The Berkshelf

Crowbar uses Berkshelf to help manage cookbooks.  Berkshelf resolves cookbook dependencies by following the Berksfile instructions for local and remote dependent cookbooks.  It stores dependencies in the Berkshelf (path.)  If you're using a Chef Server, it can uploads them to the Chef Server.  If you're using chef-solo or chef-client -x, it can do a few thins to help you.  It can put them on the filesystem somewhere for you to pick up and deliver to your nodes (perhaps delivered by NFS), or it can even packages them into tar.gz archives for delivery to nodes and unpacking. 

### Prerequisites

  1. We encourage you to clone from the OpenCrowbar github organization and submit pull requests.
  1. All cookbooks are to be "vendorized." That is, they're prefixed with an organization name, i.e. your identifier.
    1. It does not preclude you from using application/library cookbook strategies, because it has no effect on resource scoping within a chef-client run.
> core/chef/crowbar/cookbooks/dhcp/recipes/default.rb
> core/chef/newgoliath/cookbooks/mydhcp/recipes/default.rb
  1. It's expected that all cookbooks will be separate git repositories.
> core/chef/newgoliath/cookbooks/mydhcp/.git/

### Developing

  1. It will resolve your dependencies expressed in your Berksfile and in your metadata.rb and install those dependencies in the Berkshelf.
  1. The Berkshelf is located at /root/.berkshelf/  Do not edit it.
  1. You probably want the cookbooks you indicated as dependents to be available to you for reference while you're developing.  The following example will download them and put them in the right place for you.

> berks install -b ./newgoliath/cookbooks/apache2/Berksfile -p ./newgoliath/cookbooks/

### Deploying

  1. Crowbar's chef-jig and chef-solo-jig will recognize cookbooks under `[ core | <barclamp> ]/chef/<vendor>/cookbooks/` as your Chef repository and upload them to the Chef Server or package them up for delivery to nodes for execution by chef-solo.


### Testing Cookbooks



  1. It's expected that you'll be creating a Berksfile in each of your cookbooks, so Crowbar can package up and delivery your cookbooks when the chef-jig and chef-solo-jig run


##Edit Documentation

You do NOT need a local clone to update docs!  You can edit them right from your fork on Github.  Just make the changes and then create a pull request.  

We love DOCS changes.
