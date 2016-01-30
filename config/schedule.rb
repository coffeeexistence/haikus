every 1.day, at: "12:00 AM"  do
  rake "db:remove_old_uuids"
end
