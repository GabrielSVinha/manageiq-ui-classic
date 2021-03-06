class TreeBuilderSmartproxyAffinity < TreeBuilder
  has_kids_for Hash, [:x_get_tree_hash_kids]
  has_kids_for MiqServer, [:x_get_server_kids]

  def initialize(name, type, sandbox, build = true, data)
    @data = data
    super(name, type, sandbox, build)
  end

  private

  def override(node, _object, _pid, _options)
    node[:cfmeNoClick] = true
  end

  def tree_init_options(_tree_name)
    {:full_ids => false, :add_root => false, :lazy => false}
  end

  def set_locals_for_render
    locals = super
    locals.merge!(:checkboxes   => true,
                  :onclick      => false,
                  :three_checks => true,
                  :post_check   => true,
                  :oncheck      => 'miqOnClickSmartProxyAffinityCheck',
                  :check_url    => '/ops/smartproxy_affinity_field_changed/')
  end

  def root_options
    {}
  end

  def x_get_tree_roots(count_only = false, _options)
    nodes = @data.miq_servers.select(&:is_a_proxy?).sort_by { |s| [s.name, s.id] }
    count_only_or_objects(count_only, nodes)
  end

  def x_get_server_kids(parent, count_only = false)
    nodes = {'host' => 'pficon pficon-screen', "storage" => 'fa fa-database'}.map do |kid, icon|
      {:id              => "#{parent.id}__#{kid}",
       :icon            => icon,
       :parent          => parent,
       :text            => Dictionary.gettext(kid.camelcase, :type => :model, :notfound => :titleize, :plural => true),
       :cfmeNoClick     => true,
       :nodes           => @data.send(kid.pluralize).sort_by(&:name),
       :smartproxy_kind => kid}
    end
    count_only_or_objects(count_only, nodes)
  end

  def x_get_tree_hash_kids(parent, count_only = false)
    affinities = parent[:parent].send("vm_scan_#{parent[:smartproxy_kind]}_affinity").collect(&:id) if parent[:parent].present?
    nodes = parent[:nodes].map do |kid|
      {:id              => "#{parent[:id]}_#{kid.id}",
       :icon            => parent[:icon],
       :text            => kid.name,
       :select          => affinities.include?(kid.id),
       :cfmeNoClick     => true,
       :nodes           => [],
       :smartproxy_kind => parent[:smartproxy_kind]}
    end
    count_only_or_objects(count_only, nodes)
  end
end
