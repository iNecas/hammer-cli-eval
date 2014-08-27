org     = foreman.organizations.find_or_create(name: 'Default_Organization')
product = org.products.create_or_create(name: 'Foreman')
repo    = product.repositories.find_or_create(name: 'nightly el6 x86_64',
                                              url: 'http://yum.theforeman.org/nightly/el6/x86_64/',
                                              publish_via_http: true)
