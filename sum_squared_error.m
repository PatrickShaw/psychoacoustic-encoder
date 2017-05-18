function result = sum_squared_error(original, new)
    result = sum((original - new).^2);
end