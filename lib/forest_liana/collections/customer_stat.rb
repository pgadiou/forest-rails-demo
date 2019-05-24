class Forest::CustomerStat
  include ForestLiana::Collection

  collection :CustomerStat, is_searchable: true

  field :id, type: 'Number', is_read_only: true
  field :email, type: 'String', is_read_only: true
  field :orders, type: 'String', is_read_only: true
  field :amount, type: 'Number', is_read_only: true


  # is_searchable: true
end
