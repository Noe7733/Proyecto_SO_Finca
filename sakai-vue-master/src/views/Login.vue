<script setup>
import { useLayout } from '@/layout/composables/layout';
import { ref, computed } from 'vue';
import AppConfig from '@/layout/AppConfig.vue';
import router from '../router';
import axios from 'axios'; // Asegúrate de importar Axios si no lo has hecho
import sha256 from 'crypto-js/sha256';


const { layoutConfig } = useLayout();
const email = ref('');
const password = ref('');
const checked = ref(false);

// const directecDahs = async () => {
//     const hashedPassword = sha256(password.value).toString();

//     try {
//         const response = await axios.post('http://localhost:3000/ValidaUser', {
//             nombreusu: email.value,
//             password: hashedPassword,
//         });

//         if (response.data.success) {
//             router.push('/dash');
//         } else {
//             console.error('Inicio de sesión fallido');
//         }
//     } catch (error) {
//         console.error('Error al iniciar sesión:', error.message);
//     }
// };

const predefinedUser = 'najera';
const predefinedPassword = 'najera';

const directecDahs = async () => {
    if (email.value === predefinedUser && password.value === predefinedPassword) {
        router.push('/dash');
        this.$toast.add({ severity: 'success', summary: '¡Inicio de sesión exitoso!', detail: '¡Bienvenido usuario najera!', life: 1000 });
    } else {
        console.error('Inicio de sesión fallido');
        this.$toast.add({ severity: 'warn', summary: '¡Inicio de sesión fallido!', detail: '¡Usuario o contraseña incorrecta!', life: 1000 });
    }
};

const logoUrl = computed(() => {
    return `layout/images/${layoutConfig.darkTheme.value ? 'logo-white' : 'logo-dark'}.svg`;
});
</script>

<template>
    
    <div class="surface-ground flex align-items-center justify-content-center min-h-screen min-w-screen overflow-hidden">
        <div class="flex flex-column align-items-center justify-content-center">
            <div style="border-radius: 56px; padding: 0.3rem; background: linear-gradient(180deg, var(--primary-color) 10%, rgba(33, 150, 243, 0.7) 100%)">
                <div class="w-full surface-card py-8 px-5 sm:px-8" style="border-radius: 53px">
                    <div class="text-center mb-5">
                        <img src="/demo/images/login/avatar.png" alt="Image" height="50" class="mb-3" />
                        <div class="text-900 text-3xl font-medium mb-3">Bienvenido al Sistema Finca Nuevo Cafe</div>
                        <span class="text-600 font-medium">Inicia sesión para continuar</span>
                    </div>

                    <div>
                        <label for="email1" class="block text-900 text-xl font-medium mb-2">Email</label>
                        <InputText id="email1" type="text" placeholder="Email address" class="w-full md:w-40rem mb-5" style="padding: 1rem" v-model="email" />
                        <label for="password1" class="block text-900 font-medium text-xl mb-2">Password</label>
                        <Password id="password1" v-model="password" placeholder="Password" :toggleMask="true" class="w-full mb-5" inputClass="w-full" :inputStyle="{ padding: '1rem' }"></Password>
                        <div class="flex align-items-center justify-content-between mb-5 gap-5">
                            <div class="flex align-items-center">
                                <Checkbox v-model="checked" id="rememberme1" binary class="mr-2"></Checkbox>
                                <label for="rememberme1">Remember me</label>
                            </div>
                            <!-- <a class="font-medium no-underline ml-2 text-right cursor-pointer" style="color: var(--primary-color)">Forgot password?</a> -->
                        </div>
                        <Button label="Iniciar Sesion" class="w-full p-3 text-xl" @click="directecDahs"></Button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <AppConfig simple />
</template>

<style scoped>
.pi-eye {
    transform: scale(1.6);
    margin-right: 1rem;
}

.pi-eye-slash {
    transform: scale(1.6);
    margin-right: 1rem;
}

.surface-ground {
    position: relative;
    background-image: url('/demo/images/login/fincas.jpg');
    background-size: cover;
    background-position: center;
}

.surface-card {
    backdrop-filter: blur(10px);
    background: rgba(65, 133, 110, 0.963); /* Establece la opacidad aquí */
    /* Otros estilos que ya tienes o necesitas */
}
</style>