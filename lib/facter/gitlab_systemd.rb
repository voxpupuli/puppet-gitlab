# Fact: gitlab_systemd
#
# Purpose: 
#   Determine whether SystemD is the init system on the node
#
# Resolution:
#   Check the name of the process 1 (ps -p 1)
#
# Caveats:
#	Duplicates the fact "systemd" from camptocamp/puppet-systemd
#

Facter.add(:gitlab_systemd) do
  confine :kernel => :linux
  setcode do
    %x{ps -p 1 -o comm=}.gsub("\n",'') == 'systemd'
  end
end
