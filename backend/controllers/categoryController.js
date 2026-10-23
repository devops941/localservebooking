const Category = require('../models/Category');
const { sendSuccess, sendError } = require('../utils/response');

// Get all active categories (Public)
const getCategories = async (req, res) => {
  try {
    let categories = await Category.find().sort({ createdAt: 1 });

    // Seed default categories if empty
    if (categories.length === 0) {
      const defaultCategories = [
        { name: 'Electrician', icon: 'electrical_services', startingPrice: 199, description: 'Wiring, fixtures & fans' },
        { name: 'Plumbing', icon: 'plumbing', startingPrice: 249, description: 'Taps, leakage & pipeline fix' },
        { name: 'Home Cleaning', icon: 'cleaning_services', startingPrice: 499, description: 'Deep room & kitchen sanitization' },
        { name: 'AC Repair', icon: 'ac_unit', startingPrice: 399, description: 'Wet wash, gas refilling & repair' },
        { name: 'Carpentry', icon: 'carpenter', startingPrice: 299, description: 'Door locks, furniture repair' },
        { name: 'Painting', icon: 'format_paint', startingPrice: 799, description: 'Wall painting & waterproofing' },
        { name: 'Appliance Repair', icon: 'kitchen', startingPrice: 349, description: 'Fridge, washing machine & microwave' },
        { name: 'Pest Control', icon: 'pest_control', startingPrice: 599, description: 'Termite, bug & rodent protection' },
      ];
      categories = await Category.insertMany(defaultCategories);
    }

    return sendSuccess(res, 'Categories retrieved.', {
      count: categories.length,
      categories,
    });
  } catch (error) {
    return sendError(res, `Failed to get categories: ${error.message}`, 500);
  }
};

// Get single category
const getCategoryById = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) {
      return sendError(res, 'Category not found.', 404);
    }
    return sendSuccess(res, 'Category retrieved.', { category });
  } catch (error) {
    return sendError(res, `Failed to get category: ${error.message}`, 500);
  }
};

// Create category (Admin only)
const createCategory = async (req, res) => {
  try {
    const { name, icon, description, startingPrice } = req.body;
    if (!name) {
      return sendError(res, 'Category name is required.', 400);
    }

    const category = await Category.create({
      name,
      icon,
      description,
      startingPrice,
    });

    return sendSuccess(res, 'Category created successfully.', { category }, 201);
  } catch (error) {
    return sendError(res, `Failed to create category: ${error.message}`, 500);
  }
};

// Update category (Admin only)
const updateCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!category) {
      return sendError(res, 'Category not found.', 404);
    }
    return sendSuccess(res, 'Category updated successfully.', { category });
  } catch (error) {
    return sendError(res, `Failed to update category: ${error.message}`, 500);
  }
};

// Delete category (Admin only)
const deleteCategory = async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) {
      return sendError(res, 'Category not found.', 404);
    }
    return sendSuccess(res, 'Category deleted successfully.');
  } catch (error) {
    return sendError(res, `Failed to delete category: ${error.message}`, 500);
  }
};

module.exports = {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
};
