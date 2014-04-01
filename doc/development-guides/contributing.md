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

Crowbar uses Berkshelf to help manage cookbooks.  Berkshelf resolves cookbook dependencies by following the Berksfile instructions for local and remote dependent cookbooks.  It stores dependencies in the Berkshelf (path.)  If you're using a Chef Server, it can upload them to the Chef Server.  If you're using chef-solo or chef-client -x, it packages them on the filesystem  and delivers them to your nodes. 

### Prerequisites

  * Currently, `berks` runs as `root`.  Files created by Berkshelf will be owned by `root`.  There is no forseen harm in this.
  * We encourage you to clone from the OpenCrowbar github organization and submit pull requests.
  * All cookbooks are to be "vendorized." That is, they're prefixed with an organization name, i.e. your identifier.
    * It does not preclude you from using application/library cookbook strategies, because it has no effect on resource scoping within a chef-client run.
```
core/chef/crowbar/cookbooks/dhcp/recipes/default.rb
core/chef/newgoliath/cookbooks/mydhcp/recipes/default.rb
```
  * It's expected that all cookbooks will be separate git repositories.
```
core/chef/newgoliath/cookbooks/mydhcp/.git/
```
  * These apply for the Barclamps as well:
```
<barclamp>/chef/<organization>/cookbooks/
openstack/chef/newgoliath/cookbooks/
```

### Developing Barclamps

  * The Jig will resolve your dependencies expressed in your Berksfile and in your metadata.rb and install those dependencies in the Berkshelf.
  * The Berkshelf is located at /root/.berkshelf/  Do not edit it.  If you want to prune it of old and unnecessary versions of cookbooks, feel free to use `sudo berks shelf uninstall <cookbook> -v <version>`  The Chef Jig should replace any missing versions of cookbooks in the Berkshelf next time it runs.
  * You probably want the cookbooks you indicated as dependents to be available to you for reference while you're developing.  The following example will download them and put them in the right place for you.

```
cd <opencrowbar_root>/core/chef/
sudo berks install -b ./newgoliath/cookbooks/apache2/Berksfile -p ./newgoliath/deploy/
```

### Developing OpenCrowbar Core

  * This does not apply to the bootstrapping process.  It only applies to the OpenCrowbar admin server once it is bootstrapped.
  * OpenCrowbar core uses chef-solo.  It will simply `berks install --path <opencrowbar_root>/core/chef/deploy` on all the cookbooks found in `<opencrowbar_root>/core/<vendor>/cookbooks/`.  This will put all the cookbooks and their depenency in executable format in the deploy directory indicated above.

### Testing Cookbooks

TODO: Script this, possibly under 'tools'

   * create a test node (a kvm node is just fine)
   * add it to a deployment and add the node-role that your cookbook belongs to
   * kick off the annealer to deploy your cookbooks to a test node.

FUTURE:

   * Crowbar can help integrate your normal testing patterns.  We're considering `test-kitchen` integration.

### Deploying to your nodes

  * Crowbar's chef-jig will use `sudo berks upload` to send the cookbooks and depenencies from ALL the vendor cookbook directories to the Chef Server.  Be careful what you put in your vendor cookbook directory.
  * Similarly, the chef-solo-jig will recognize ALL vendor cookbooks and package them up for delivery to nodes for execution by chef-solo.

### How it works in production

  * The Chef-jig keeps track of noderoles, attributes, and honors the versions in the Berksfile and Berksfile.lock for each cookbook.  The Berksfile.lock is to track the current best cookbook version for the system.  The Berksfile indicates the compatible versions, and the versions to be installed into the Berkshelf
  * When the Chef-jig runs, it examines the modify timestamps and, if necessary, checks `shasums` on each of the cookbooks in <barclamp>/chef/<vendor>/cookbooks/ and any appropriate package names in <barclamp>/chef/<vendor>/deploy/
  * If anything has changed, Chef-Jig uses `berks install; berks package -o <barclamp>/chef/deploy/` to update the Berkshelf and create new packages


##Edit Documentation

You do NOT need a local clone to update docs!  You can edit them right from your fork on Github.  Just make the changes and then create a pull request.  

We love DOCS changes.
