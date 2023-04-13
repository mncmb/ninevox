## minAD Tierit
`The beacons are lit.` 

Vagrantfile for provisioning a tiered active directory network environment. Useful for practicing pivoting and testing out C2 features.   

Creates a minimal AD deployment. Use some kind of `AD generator` to populate it.   
Take a look at `bigwhoop` template directory or use [theMayors ADgen](https://github.com/dievus/ADGenerator) (or get the course), where the architecture is based on.

![netplan minad](../pics/minad.jpg)

## starting point
When adding an attacking machine you want to add it to the `outer_reaches` network for max pivoting potential.


Or simply deploy the included kali machine by uncommenting it from the vagrantfile.