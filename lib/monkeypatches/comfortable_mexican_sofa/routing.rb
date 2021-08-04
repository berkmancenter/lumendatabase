# Monkeypatch to make the comfortable_mexican_sofa gem work with Ruby 3.x,
# remove it when the gem is fixed.

class ActionDispatch::Routing::Mapper
  def comfy_route(identifier, options = {})
    send("comfy_route_#{identifier}", **options)
  end
end
