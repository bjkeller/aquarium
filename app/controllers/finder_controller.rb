class FinderController < ApplicationController

  before_filter :signed_in_user

  def projects
    render json: (Sample.all.collect { |s| { id: 0, name: s.project } }).uniq.sort { |a,b| a[:name] <=> b[:name] }
  end

  def types
    spec = JSON.parse( params[:spec], symbolize_names: true )
    render json: (Sample.includes('sample_type').where("project = ?", spec[:project]).collect{|s| { id: s.sample_type.id, name: s.sample_type.name } }).uniq.sort { |a,b| a[:name] <=> b[:name] }
  end

  def samples
    spec = JSON.parse( params[:spec], symbolize_names: true )
    s = Sample.joins(:sample_type).where(project: spec[:project], sample_types: { name: spec[:type] } )
    render json: (s.collect{|s| { id: s.id, name: s.name } }).uniq.sort { |a,b| a[:name] <=> b[:name] }
  end

  def containers
    spec = JSON.parse( params[:spec], symbolize_names: true )
    logger.info "SPEC = #{spec}"
    render json: (ObjectType.joins(:items => :sample).where(:samples => { project: spec[:project], name: spec[:sample] }).collect { |o| { id: o.id, name: o.name } }).uniq.sort { |a,b| a[:name] <=> b[:name] }
  end

  def items
    spec = JSON.parse( params[:spec], symbolize_names: true )
    render json: (Item.joins(:sample,:object_type).where(:samples => { project: spec[:project], name: spec[:sample] }, :object_types => { name: spec[:container] }).collect { |i| { id: i.id, name: i.id } }).sort  { |a,b| a[:name] <=> b[:name] }
  end

  def sample_info 
    spec = JSON.parse( params[:spec], symbolize_names: true )
    s = Sample.find(spec[:sample_id])
    props = { id: s.id, name: s.name, created_at: s.created_at, updated_at: s.updated_at, description: s.description }
    (1..8).each do |i|
      prop = s.sample_type["field#{i}name"] 
      if prop != "" && prop != nil
        props[s.sample_type["field#{i}name"].to_sym] = s["field#{i}"]
      end
    end
    render json: props
  end

end