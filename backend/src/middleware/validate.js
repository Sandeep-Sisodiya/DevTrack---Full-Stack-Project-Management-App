const { validationResult } = require('express-validator');

// Middleware that checks express-validator results and returns 400 if invalid
const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const messages = errors.array().map((err) => err.msg);
    return res.status(400).json({ message: 'Validation failed', errors: messages });
  }

  next();
};

module.exports = validate;
