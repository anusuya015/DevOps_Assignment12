from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import time

# Replace with your deployed app URL
url = "http://44.210.9.223:8000"

driver = webdriver.Chrome()  # or Firefox()
driver.get(url)

# Login test
username_input = driver.find_element(By.NAME, "username")
password_input = driver.find_element(By.NAME, "password")
login_button = driver.find_element(By.ID, "login-btn")

username_input.send_keys("ITA706")
password_input.send_keys("2022PE0175")
login_button.click()

time.sleep(2)

# Check home page text
home_text = driver.find_element(By.TAG_NAME, "body").text
assert "Hello ITA700" in home_text

# Logout
logout_button = driver.find_element(By.ID, "logout-btn")
logout_button.click()

driver.quit()
