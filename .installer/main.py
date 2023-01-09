from app import App

app = App()
result = app.render_welcome_screen()
app.clear()
if result:
    result = app.query_os()
    app.clear()
    print(result)
