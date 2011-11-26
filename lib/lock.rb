class Lock; end

class << Lock

   def use lock_file
     @lock_file = lock_file
   end

   def locked?
     File.exist? @lock_file
   end

   def lock
     system "touch #{@lock_file}"
   end

   def unlock
     lock
     system "rm #{@lock_file}"
   end

end
