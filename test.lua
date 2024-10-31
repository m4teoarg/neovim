-- Definir la función para sumar dos números
function suma(a, b)
	return a + b
end

local vim = vim

-- Función para mostrar resultados en una ventana flotante
function Resultado()
	local resultado = suma(5, 7)
	local output = "La suma es: " .. resultado

	-- Crear una ventana flotante
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { output })

	local width = vim.o.columns
	local height = vim.o.lines

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.ceil(width * 0.5),
		height = math.ceil(height * 0.1),
		col = math.ceil(width * 0.25),
		row = math.ceil(height * 0.2),
		style = "minimal",
		-- border = "single",
	})

	-- Cerrar la ventana flotante después de 3 segundos
	vim.defer_fn(function()
		vim.api.nvim_win_close(win, true)
	end, 10000)
end

-- Asignar un keymap para ejecutar la función y mostrar el resultado
vim.keymap.set("n", "<leader>ms", ":lua Resultado()<CR>", { noremap = true, silent = true })
