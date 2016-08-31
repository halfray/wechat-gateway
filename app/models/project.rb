class Project < Fume::Settable::Base
  yaml_provider Rails.root.join("config/gate_way.yml")
end