require 'pp'

TEST_ALL = EXTRA_ARGV.include?('all')

org     = foreman.organizations.find_or_create(:name => 'Default_Organization')
show org

product = org.products.find_or_create(:name => 'Zoo Product')
show product

repo    = product.repositories.find_or_create(:name => 'zoo 1.0',
                                              :url => 'https://inecas.fedorapeople.org/fakerepos/new_cds/content/zoo/1.0/x86_64/rpms/',
                                              :content_type => 'yum',
                                              :unprotected => true)
show repo

if TEST_ALL
  other_product = org.products.find_or_create(:name => 'to-be-deleted')
  other_product.destroy
  begin
    other_product.reload
    raise 'successful reload of destroyed product: something is worng here'
  rescue RestClient::ResourceNotFound => e
    # Expected
  end
end

if TEST_ALL
  product.name = "New name"
  product.reload
  raise 'the name was not reloaded' if product.name == "New name"

  if false
    default_view = org.content_views.find_by_uniq(:name => "Default Organization View")
  end
end

if TEST_ALL
  repo.sync.wait
end

if TEST_ALL
  ak = org.activation_keys.find_or_create(:name => 'zoo')
  show ak
end

# TODO
# content_view = org.content_views.find_or_create(:name => "Foreman")
# content_view.repositories << repo
# content_view.save
# content_view.publish.wait
# composite_view = org.content_views.find_or_create(:name => "Foreman On Rhel", :composite => true)
# composite_view.content_views << content_view
# composite_view.save
# composite_view.publish.wait
# ak = composite_view.activation_keys.find_or_create(:name => "foreman-on-rhel")
# ak.subscriptions << product.pools.first
# ak.save

#product.destroy
