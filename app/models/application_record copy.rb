class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include Referenceable
  # has_paper_trail

  def execute_statement(sql)
    # records = ActiveRecord::Base.connection.exec_query(sql)
    records = ActiveRecord::Base.connection.execute(sql)
    if records.present?
      return records
    else
      return nil
    end
  end

  def execute_query(sql)
    records = ActiveRecord::Base.connection.exec_query(sql)
    # records = ActiveRecord::Base.connection.execute(sql)
    if records.present?
      return records
    else
      return nil
    end
  end


end
