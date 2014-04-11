module Lang

  class Scope 

    def tasks prototype, status

      tp = TaskPrototype.find_by_name(prototype)

      if tp
        Task.where("task_prototype_id = ? AND status = ?", tp.id, status).collect do |t| 
          result = t.attributes.symbolize_keys
          result[:specification] = JSON.parse(result[:specification], symbolize_names: true)
          result
        end
      else
        []
      end

    end

    def get_task_status task

      t = Task.find_by_id( task[:id] )

      if t
        t.status
      else
        "UNKNOWN TASK"
      end

    end

    def set_task_status task, status

      t = Task.find_by_id( task[:id] )

      if t

        t.status = status
        t.save
        puts "Current job = %{CURRENT_JOB_ID}"

        touch = Touch.new
        touch.job_id = $CURRENT_JOB_ID
        touch.task_id = t.id
        touch.save

      end

    end

  end

end
