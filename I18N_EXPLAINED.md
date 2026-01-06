# 🌍 Internationalization (I18n) - Explained Simply

## What is I18n?

### In Simple Words:

**Internationalization (I18n)** = Making your app work in **multiple languages**

Instead of writing text directly in your code like this:
```ruby
<h1>Welcome to EventHub</h1>
```

You write it like this:
```ruby
<h1><%= t('welcome.title') %></h1>
```

Then you define translations in **YAML files**:

**English (en.yml):**
```yaml
en:
  welcome:
    title: "Welcome to EventHub"
```

**Spanish (es.yml):**
```yaml
es:
  welcome:
    title: "Bienvenido a EventHub"
```

**Urdu (ur.yml):**
```yaml
ur:
  welcome:
    title: "ایونٹ ہب میں خوش آمدید"
```

### Why Use I18n?

✅ **Support multiple languages** (English, Spanish, Urdu, etc.)
✅ **Easy to change text** (all in one place)
✅ **No code changes** when adding new languages
✅ **Professional apps** use it (Facebook, Twitter, Amazon)

---

## How I18n Works

### The Magic Formula:

```
1. You write:    I18n.t("hello")
                 ↓
2. Rails looks in: config/locales/en.yml
                 ↓
3. Finds:        hello: "Hello world"
                 ↓
4. Returns:      "Hello world"
```

### Example in Real Life:

**Your view file:**
```erb
<h1><%= I18n.t("hello") %></h1>
```

**Translation file (config/locales/en.yml):**
```yaml
en:
  hello: "Hello world"
```

**What user sees:**
```
Hello world
```

---

## Where I18n is Used in Your Code

### 1. **Admin Dashboard Title**

**File:** `app/admin/dashboard.rb:2-4`

```ruby
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
```

**What this does:**
```
I18n.t("active_admin.dashboard")
  ↓
Looks for translation: active_admin.dashboard
  ↓
Returns: "Dashboard" (from ActiveAdmin's built-in translations)
```

**Why use it?**
- ActiveAdmin is used worldwide
- Different countries need different languages
- If you set locale to Spanish: "Dashboard" → "Tablero"

**Example:**

```ruby
# English (default)
I18n.locale = :en
I18n.t("active_admin.dashboard")  # → "Dashboard"

# Spanish
I18n.locale = :es
I18n.t("active_admin.dashboard")  # → "Tablero"

# French
I18n.locale = :fr
I18n.t("active_admin.dashboard")  # → "Tableau de bord"
```

---

### 2. **Devise Error Messages**

**File:** `app/views/devise/shared/_error_messages.html.erb:4-6`

```erb
<h2>
  <%= I18n.t("errors.messages.not_saved",
             count: resource.errors.count,
             resource: resource.class.model_name.human.downcase)
   %>
</h2>
```

**What this does:**

```
I18n.t("errors.messages.not_saved", count: 2, resource: "user")
  ↓
Looks in: config/locales/devise.en.yml
  ↓
Finds template: "%{count} errors prohibited this %{resource} from being saved:"
  ↓
Fills in variables:
  - %{count} → 2
  - %{resource} → user
  ↓
Returns: "2 errors prohibited this user from being saved:"
```

**Why use it?**

When user makes mistakes during signup, show error in their language:

**English:**
```
2 errors prohibited this user from being saved:
• Email can't be blank
• Password is too short
```

**Spanish:**
```
2 errores impidieron que este usuario fuera guardado:
• El email no puede estar en blanco
• La contraseña es demasiado corta
```

---

### 3. **Default "Hello World"**

**File:** `config/locales/en.yml:33`

```yaml
en:
  hello: "Hello world"
```

**Usage:**
```ruby
I18n.t("hello")  # → "Hello world"
```

This is just a demo example from Rails. Not used in your app currently.

---

## Your Translation Files

### File Structure:

```
config/locales/
├── en.yml              # English translations (main app)
└── devise.en.yml       # English translations (Devise gem)
```

### 1. **Main App Translations**

**File:** `config/locales/en.yml`

```yaml
en:
  hello: "Hello world"
```

**Current translations:**
- Only has `hello` (demo example)
- You can add more!

---

### 2. **Devise Translations**

**File:** `config/locales/devise.en.yml`

This file contains ALL Devise messages:
- Login/signup errors
- Password reset messages
- Email confirmation texts
- Success/failure messages

**Example from this file:**

```yaml
en:
  devise:
    confirmations:
      confirmed: "Your email address has been successfully confirmed."
      send_instructions: "You will receive an email with instructions..."

    passwords:
      send_instructions: "You will receive an email with password reset..."
      updated: "Your password has been changed successfully."

    sessions:
      signed_in: "Signed in successfully."
      signed_out: "Signed out successfully."

    registrations:
      signed_up: "Welcome! You have signed up successfully."
```

**When you see messages like:**
```
"Signed in successfully"
"Your password has been changed successfully"
```

These come from `devise.en.yml`!

---

## How to Use I18n in Your Code

### In Views (.erb files):

**Shorthand:**
```erb
<h1><%= t('hello') %></h1>
```

**Full version:**
```erb
<h1><%= I18n.t('hello') %></h1>
```

Both are the same! `t()` is just a shortcut for `I18n.t()`

### In Controllers/Models (.rb files):

**Full version only:**
```ruby
I18n.t('hello')
```

### With Variables:

**Translation file:**
```yaml
en:
  welcome:
    message: "Hello %{name}, you have %{count} new messages"
```

**In code:**
```ruby
I18n.t('welcome.message', name: "John", count: 5)
# → "Hello John, you have 5 new messages"
```

---

## How Rails Knows Which Language to Use

### Default Language:

**File:** `config/application.rb`

```ruby
config.i18n.default_locale = :en  # English is default
```

### Changing Language Dynamically:

```ruby
# Set language for current request
I18n.locale = :es  # Spanish
I18n.locale = :ur  # Urdu
I18n.locale = :fr  # French
```

### Example in Controller:

```ruby
class ApplicationController < ActionController::Base
  before_action :set_locale

  private

  def set_locale
    # Use user's preferred language from profile
    I18n.locale = current_user&.preferred_language || :en
  end
end
```

---

## Why Your App Uses I18n (Even in English Only)

### 1. **ActiveAdmin is International**

ActiveAdmin (your admin panel) is used worldwide. It has built-in translations for:
- Dashboard
- Filters
- Actions (Edit, Delete, View)
- Buttons (Create, Update, Cancel)
- Messages (Created successfully, etc.)

**All these use I18n!**

### 2. **Devise is International**

Devise (authentication) has translations for:
- Login/signup forms
- Error messages
- Email subjects
- Success messages

**Example:**
```ruby
# When user signs in:
I18n.t("devise.sessions.signed_in")
# → "Signed in successfully."
```

### 3. **Easy to Add Languages Later**

Right now your app is English only. But **if you want to add Urdu, Spanish, or Arabic later**, you just:

1. Create new file: `config/locales/ur.yml`
2. Add translations
3. Done!

**No code changes needed!**

---

## Real Example: Adding Urdu Support

### Step 1: Create Urdu Translation File

**File:** `config/locales/ur.yml`

```yaml
ur:
  hello: "السلام علیکم"

  welcome:
    title: "ایونٹ ہب میں خوش آمدید"
    message: "آپ کے %{count} نئے پیغامات ہیں"
```

### Step 2: Use in Controller

```ruby
class EventsController < ApplicationController
  before_action :set_locale

  def index
    @greeting = I18n.t('hello')
    # English: "Hello world"
    # Urdu: "السلام علیکم"
  end

  private

  def set_locale
    I18n.locale = params[:locale] || :en
  end
end
```

### Step 3: Language Switcher in View

```erb
<%= link_to "English", root_path(locale: :en) %>
<%= link_to "اردو", root_path(locale: :ur) %>
```

**That's it!** Your app now supports Urdu! 🎉

---

## Common I18n Patterns

### 1. **Nested Keys**

**Translation file:**
```yaml
en:
  events:
    index:
      title: "All Events"
      subtitle: "Browse upcoming events"
    show:
      register: "Register Now"
      price: "Price: $%{amount}"
```

**Usage:**
```ruby
I18n.t('events.index.title')      # → "All Events"
I18n.t('events.show.price', amount: 100)  # → "Price: $100"
```

### 2. **Pluralization**

**Translation file:**
```yaml
en:
  ticket:
    one: "1 ticket"
    other: "%{count} tickets"
```

**Usage:**
```ruby
I18n.t('ticket', count: 1)   # → "1 ticket"
I18n.t('ticket', count: 5)   # → "5 tickets"
```

### 3. **Default Values**

```ruby
I18n.t('missing.key', default: "Fallback text")
# If missing.key doesn't exist, returns "Fallback text"
```

---

## Where ActiveAdmin Translations Come From

ActiveAdmin has its own translation files inside the gem:

```
~/.rvm/gems/ruby-3.3.0/gems/activeadmin-X.X.X/
└── config/locales/
    ├── en.yml          # English
    ├── es.yml          # Spanish
    ├── fr.yml          # French
    ├── ar.yml          # Arabic
    └── ... (50+ languages!)
```

**When you use:**
```ruby
I18n.t("active_admin.dashboard")
```

Rails looks in:
1. Your `config/locales/` first
2. Then ActiveAdmin's built-in locales
3. Returns the translation

---

## Testing I18n

### In Rails Console:

```bash
rails console
```

```ruby
# Check current locale
I18n.locale
# → :en

# Get translation
I18n.t("hello")
# → "Hello world"

# Change locale
I18n.locale = :es

# Get translation in Spanish
I18n.t("hello")
# → "Hola mundo" (if es.yml exists)

# Check all available locales
I18n.available_locales
# → [:en]

# Check translation with variables
I18n.t('events.show.price', amount: 100)
# → "Price: $100"
```

---

## Summary: Where I18n is Used in Your App

| Location | What | Why |
|----------|------|-----|
| `app/admin/dashboard.rb:2` | Dashboard menu label | ActiveAdmin multi-language support |
| `app/admin/dashboard.rb:4` | Dashboard page title | ActiveAdmin multi-language support |
| `app/views/devise/shared/_error_messages.html.erb:4` | Signup/login error messages | Show errors in user's language |
| `config/locales/en.yml:33` | Demo "hello" translation | Example placeholder |
| `config/locales/devise.en.yml` | ALL Devise messages | Login, signup, password reset, etc. |

---

## Key Takeaways

### ✅ **What is I18n?**
- System for supporting multiple languages
- Separates text from code
- Text stored in YAML files

### ✅ **Why use it?**
- Easy to add new languages
- Professional standard
- No code changes needed
- Used by ActiveAdmin & Devise

### ✅ **How to use it?**
```ruby
# In views:
<%= t('key') %>

# In code:
I18n.t('key')

# With variables:
I18n.t('key', name: "John", count: 5)
```

### ✅ **In your app:**
- Currently **English only**
- Used by ActiveAdmin (admin panel)
- Used by Devise (authentication)
- **Ready to add more languages** anytime!

---

## How to Add a New Language to Your App

### Example: Adding Spanish

**1. Create Spanish translation file:**

`config/locales/es.yml`
```yaml
es:
  hello: "Hola mundo"

  events:
    index:
      title: "Todos los Eventos"
```

**2. Create Spanish Devise translations:**

`config/locales/devise.es.yml`
```yaml
es:
  devise:
    sessions:
      signed_in: "Sesión iniciada correctamente."
      signed_out: "Sesión cerrada correctamente."
```

**3. Add language switcher:**

`app/views/layouts/application.html.erb`
```erb
<%= link_to "English", root_path(locale: :en) %>
<%= link_to "Español", root_path(locale: :es) %>
```

**4. Set locale in controller:**

`app/controllers/application_controller.rb`
```ruby
before_action :set_locale

private

def set_locale
  I18n.locale = params[:locale] || I18n.default_locale
end
```

**Done!** Your app now supports Spanish! 🇪🇸

---

## Bonus: I18n Best Practices

### ✅ **DO:**
- Use descriptive keys: `events.show.register_button` ✅
- Group related translations: `events:`, `users:`, etc.
- Use variables for dynamic content: `%{name}`, `%{count}`

### ❌ **DON'T:**
- Use generic keys: `button1`, `text2` ❌
- Hardcode text in views: `<h1>Welcome</h1>` ❌
- Mix languages in same file

---

**Last Updated:** January 6, 2026
**Current Languages:** English only
**Ready for:** Spanish, Urdu, French, Arabic, and 50+ more!
