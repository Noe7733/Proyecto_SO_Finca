<script setup>
import { FilterMatchMode } from 'primevue/api';
import { ref, onMounted, onBeforeMount } from 'vue';
import ProductService from '@/service/ProductService';
import { useToast } from 'primevue/usetoast';

const toast = useToast();

</script>

<script>
import axios from "axios";
import { ref } from 'vue';
const productDialog = ref(false);

const openWindow = () => {
    productDialog.value = true;
};

export default {
    data() {
        return {
            usuarioo: null,
            passwordd: null,
            NombreUserr: null,

        }
    },
    mounted() {

    },
    methods: {
        async CrearUsuario() {
            if (this.usuarioo == null && this.passwordd == null && this.NombreUserr == null ) { //validación del campo nulo
                this.$toast.add({ severity: 'warn', summary: '¡Favor de Ingresar Todos lo Campos!', detail: '¡Ingresar el dato requerido!', life: 5000 });
            } else {
                try {
                    const response = await axios.post('http://localhost:3000/InsertarUsuario', { 
                        nombreusu: this.usuarioo, 
                        contrausu: this.passwordd,
                        nombrec: this.NombreUserr,

                    });
                    console.log('res', this.usuarioo);
                    console.log('res', this.passwordd);
                    console.log('res', this.NombreUserr);
                    console.log('Respuesta:', response.data);
                    this.$toast.add({ severity: 'success', summary: 'Usuario ingresado de manera exitosa', detail: '¡Todo bien!', life: 5000 });
                } catch (error) {
                    console.error('Error al hacer la solicitud POST:', error);
                    this.$toast.add({ severity: 'warn', summary: 'El usuario deseado no se ha podido registrar :( )', detail: '¡Probleas internos!', life: 5000 });
                }
            }
            // setTimeout(() => {
            //     location.reload();
            // }, 2000); 
        },

    }
};
</script>

<template>
    <div class="grid">
        <div class="col-12">
            <div class="card">
                <h3>Usuarios</h3>
                <Toast />
                <Toolbar class="mb-4">
                    <template v-slot:start>
                        <div class="my-2">
                            <Button label="Registrar Nuevo usuario" icon="pi pi-plus" class="p-button-success mr-2"
                                @click="openWindow" />
                        </div>
                    </template>
                    <template v-slot:end>
                        <span class="p-input-icon-left mb-2">
                            <i class="pi pi-search" />
                            <InputText placeholder="Usuario a buscar" style="width: 100%" />
                        </span>
                    </template>
                </Toolbar>

                <DataTable class="p-datatable-gridlines" :paginator="true" :rows="10"
                    paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
                    :rowsPerPageOptions="[5, 10, 25]"
                    currentPageReportTemplate="Visualiando {last} de {totalRecords} usuarios" responsiveLayout="scroll">
                    <Column field="idusu" header="Codigo de usuario" :sortable="true" style="width:50px"></Column>
                    <Column field="nombreusu" header="Usuario" style="width:100px"></Column>
                    <Column field="contrausu" header="Password" style="width:120px"></Column>
                    <Column field="nombrec" header="Nombre Completo" style="width:120px"></Column>
                    <Column style="width:180px">
                        <template #header>
                            Acciones
                        </template>
                        <template #body="slotProps">
                            <Button icon="pi pi-pencil" type="button" class="p-button-success p-mr-2 p-mb-1"></Button>
                            <Button icon="pi pi-trash" type="button" class="p-button-danger p-mb-1"></Button>
                        </template>
                    </Column>
                </DataTable>
                <Dialog v-model:visible="productDialog" :style="{ width: '500px' }"
                    header="Ingresar los datos para un nuevo Usuario" modal="true" class="p-fluid">
                    <div class="field">
                        <label for="name">Ingresa Un Nombre Usuario: </label>
                        <InputText id="name" v-model="usuarioo" />
                        <hr>
                        <label for="name">Ingresa una Contraseña: </label>
                        <InputText id="name" v-model="passwordd" />
                        <hr>
                        <label for="name">Nombre del Completo del Usuario: </label>
                        <InputText id="name" v-model="NombreUserr" />
                        <hr>
                        <Button label="Registar Usuario" class="p-button-raised p-button-success mr-2 mb-2"
                            @click="CrearUsuario"></Button>
                    </div>
                </Dialog>
            </div>
        </div>
    </div>
</template>
