# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
    #machine type
    config.vm.box = 'ubuntu/bionic64'

    #network location
    config.vm.network :public_network, ip: '10.0.0.204'
    config.vm.network :private_network, ip: '10.0.1.204'

    #hostname
    config.vm.hostname = 'dev-jacobwyke'
    config.hostsupdater.aliases = ['dev.jacobwyke.com', 'assets.dev.jacobwyke.com']

    #share vagrant folder
    config.vm.synced_folder '.', '/vagrant', nfs: true
    
    #set machine resources
    config.vm.provider :virtualbox do |v|
        v.customize [
            'modifyvm', :id,
            '--memory', 1024,
            '--name', 'dev-jacobwyke',
            '--cpus', 2,
            '--natdnshostresolver1', 'on',
            '--natdnsproxy1', 'on'
        ]

        v.customize [
            'setextradata', :id, 
            'VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant', '1'
        ]
    end

end
