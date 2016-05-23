module QuarzoSoftDelete

  module ClassMethods
    def act_as_quarzo_soft_delete
      send :include, InstanceMethods

      default_scope { where("(#{self.table_name}.deleted <> :deleted or #{self.table_name}.deleted is :null)", deleted: true, null: nil) }
    end
                        
    def all_active
      columns = self.columns

      has_name = false

      columns.each do |column|
        if column.name == "name"
          has_name = true
          break
        end
      end

      if has_name
        @result = self.find(:all, :conditions=> not_deleted_condition,
          :order => "name")
      else
        @result = self.find(:all, :conditions=> not_deleted_condition)
      end

      @result
    end

    def not_deleted_condition
      condition = [" (deleted <> :deleted or deleted is :null)", {
          :deleted => true, :null => nil} ]
      condition
    end

    def pages_count(conditions, rows_per_page)
      count = self.find(:all, :conditions => conditions ).length
      pages = count/rows_per_page + (count % rows_per_page >= 1 ? 1 : 0)
      pages
    end

  end

  module InstanceMethods
    def mark_as_deleted

      type = self.class

      default_foreign_key = type.to_s.foreign_key

      assossiations = type.reflect_on_all_associations(:has_many)

      removable = true

      assossiations.each do |assossiation|
        
        class_name = assossiation.name.to_s.classify
      
        foreign_key = default_foreign_key

        if assossiation.options[:class_name] != nil
          class_name = assossiation.options[:class_name]
        end

        if assossiation.options[:foreign_key] != nil
          foreign_key = assossiation.options[:foreign_key]
        end
        
        if assossiation.options[:as] != nil
          foreign_key = assossiation.options[:as].to_s + "_id"
        end
        
        #Para modelos com relacionameno N<-->N utilizando :through 
        
        if assossiation.options[:through] != nil
          through = assossiation.options[:through]
          class_name = through.to_s.classify
        end
        
        if class_name.include?(":")
          class_name = class_name.split(":").last
        end
                
        obj = Object.const_get(class_name).new

        related_class = obj.class

        columns = related_class.columns_hash

        if columns.has_key?('deleted')
          condition = foreign_key + " = :object_id AND (deleted <> :deleted or deleted is :null)"
        else
          condition = foreign_key + " = :object_id"
        end

        count = related_class.where(condition, deleted: true, null: nil, object_id: self.id).count

        if count > 0
          removable = false
          break
        end
      end

      if removable
        self.deleted = true
        return self.save(:validate => false)
      end

      return false
    end

    def unsafe_mark_as_deleted
      self.update_column(:deleted, true)
    end

    def any_active(column_name, scope = nil)

      object_class = self.class
      conds = []
      conds << [column_name.to_s + " = ? ", self[column_name]]
      conds << [" (deleted <> ? or deleted is ?) ", true, nil ]

      if self.id != nil
        conds << ["id <> ? ", self.id]
      end

      if scope != nil
        conds << [scope.to_s + " = ? ", self[scope]]
      end

      conditions = object_class.merge_conditions(*conds)

      ret = object_class.count(:conditions => conditions) > 0

      return ret

    end


  end

  ActiveRecord::Base.extend QuarzoSoftDelete::ClassMethods
end
