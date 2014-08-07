include Helpers::ModuleHelper

def init
  sections :header, [T('docstring')], :constant_list, [T('docstring')], :method_list, [T('method')]
end

def method_list
  @meths = object.meths(:inherited => false, :included => false)
  cons = @meths.find {|meth| meth.constructor? }
  @meths = @meths.reject {|meth| special_method?(meth) }
  @meths = sort_listing(prune_method_listing(@meths, false))
  @meths.unshift(cons) if cons && !cons.has_tag?(:private)
  return if @meths.empty?
  erb(:method_list)
end

def constant_list
  @constants = object.constants(:included => false, :inherited => false)
  @constants += object.cvars
  @constants = run_verifier(@constants)
  return if @constants.empty?
  erb(:constant_list)
end

def sort_listing(list)
  list.sort_by {|o| [o.scope.to_s, o.name.to_s.downcase] }
end

def special_method?(meth)
  return true if meth.writer? && meth.attr_info[:read]
  return true if meth.name(true) == 'new'
  return true if meth.name(true) == '#method_missing'
  return true if meth.constructor?
  false
end

def mixed_into(object)
  unless globals.mixed_into
    globals.mixed_into = {}
    list = run_verifier Registry.all(:class, :module)
    list.each {|o| o.mixins.each {|m| (globals.mixed_into[m.path] ||= []) << o unless m.is_a?(::YARD::CodeObjects::Proxy) } }
  end

  globals.mixed_into[object.path] || []
end
